-- Migración 006: hogares compartidos. Despensa, menú semanal y lista de la
-- compra se pueden compartir entre los miembros de un mismo hogar (p. ej.
-- pareja o familia que cocina y compra junta), uniéndose por código de
-- invitación. Un usuario pertenece como máximo a un hogar a la vez.
-- Ejecutar una vez en el SQL Editor de Supabase.

create table hogares (
  id uuid primary key default gen_random_uuid(),
  nombre text not null check (char_length(trim(nombre)) between 2 and 40),
  created_by uuid references perfiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table hogar_miembros (
  hogar_id uuid not null references hogares(id) on delete cascade,
  user_id uuid not null references perfiles(id) on delete cascade,
  rol text not null default 'miembro' check (rol in ('admin', 'miembro')),
  joined_at timestamptz not null default now(),
  primary key (hogar_id, user_id)
);
-- Un usuario solo puede estar en un hogar a la vez: mantiene el modelo
-- simple (no hay que elegir "para qué hogar" al añadir algo a la despensa).
create unique index hogar_miembros_un_hogar_por_usuario on hogar_miembros (user_id);

create table hogar_invitaciones (
  id uuid primary key default gen_random_uuid(),
  hogar_id uuid not null references hogares(id) on delete cascade,
  codigo text not null unique,
  creado_por uuid references perfiles(id) on delete set null,
  created_at timestamptz not null default now(),
  usado_por uuid references perfiles(id) on delete set null,
  used_at timestamptz
);

alter table despensa add column hogar_id uuid references hogares(id) on delete set null;
alter table menu_semanal add column hogar_id uuid references hogares(id) on delete set null;
alter table lista_compra add column hogar_id uuid references hogares(id) on delete set null;

alter table hogares enable row level security;
alter table hogar_miembros enable row level security;
alter table hogar_invitaciones enable row level security;

-- Función auxiliar (security definer) que devuelve los hogares de un
-- usuario. Se usa en las políticas RLS de abajo para evitar que
-- hogar_miembros tenga que referenciarse a sí misma en su propia política.
create or replace function public.hogares_de(p_user uuid)
returns setof uuid
language sql
security definer
set search_path = public
as $$
  select hogar_id from hogar_miembros where user_id = p_user;
$$;
grant execute on function public.hogares_de(uuid) to authenticated;

-- created_by = auth.uid() además de la pertenencia: el creador necesita
-- verse a sí mismo justo tras crear el hogar, antes de que exista su propia
-- fila en hogar_miembros (el INSERT ... RETURNING de crear_hogar exige que
-- la fila recién creada pase también la política de SELECT).
create policy "hogares_select_miembro" on hogares for select using (
  created_by = auth.uid() or id in (select public.hogares_de(auth.uid()))
);
create policy "hogares_insert_propio" on hogares for insert with check (created_by = auth.uid());

create policy "hogar_miembros_select_mismo_hogar" on hogar_miembros for select using (hogar_id in (select public.hogares_de(auth.uid())));
create policy "hogar_miembros_insert_propio" on hogar_miembros for insert with check (user_id = auth.uid());
create policy "hogar_miembros_delete_propio" on hogar_miembros for delete using (user_id = auth.uid());

create policy "hogar_invitaciones_select_miembro" on hogar_invitaciones for select using (hogar_id in (select public.hogares_de(auth.uid())));
create policy "hogar_invitaciones_insert_miembro" on hogar_invitaciones for insert
  with check (hogar_id in (select public.hogares_de(auth.uid())) and creado_por = auth.uid());

-- Sustituye las políticas "_own" de despensa/menu_semanal/lista_compra por
-- unas que también permiten ver y editar a los miembros del mismo hogar.
drop policy "despensa_own" on despensa;
create policy "despensa_own_o_hogar" on despensa for all
  using (user_id = auth.uid() or hogar_id in (select public.hogares_de(auth.uid())))
  with check (user_id = auth.uid() or hogar_id in (select public.hogares_de(auth.uid())));

drop policy "menu_semanal_own" on menu_semanal;
create policy "menu_semanal_own_o_hogar" on menu_semanal for all
  using (user_id = auth.uid() or hogar_id in (select public.hogares_de(auth.uid())))
  with check (user_id = auth.uid() or hogar_id in (select public.hogares_de(auth.uid())));

drop policy "lista_compra_own" on lista_compra;
create policy "lista_compra_own_o_hogar" on lista_compra for all
  using (user_id = auth.uid() or hogar_id in (select public.hogares_de(auth.uid())))
  with check (user_id = auth.uid() or hogar_id in (select public.hogares_de(auth.uid())));

-- Crea un hogar y añade a su creador como admin en la misma operación.
create or replace function public.crear_hogar(p_nombre text)
returns uuid
language plpgsql
security invoker
as $$
declare
  v_id uuid;
begin
  if exists (select 1 from hogar_miembros where user_id = auth.uid()) then
    raise exception 'Ya perteneces a un hogar. Sal de él antes de crear otro.';
  end if;

  insert into hogares (nombre, created_by) values (p_nombre, auth.uid()) returning id into v_id;
  insert into hogar_miembros (hogar_id, user_id, rol) values (v_id, auth.uid(), 'admin');
  return v_id;
end;
$$;
grant execute on function public.crear_hogar(text) to authenticated;

-- Genera un código de invitación de 6 caracteres para el hogar del usuario.
create or replace function public.crear_invitacion_hogar(p_hogar_id uuid)
returns text
language plpgsql
security invoker
as $$
declare
  v_codigo text;
begin
  v_codigo := upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));
  insert into hogar_invitaciones (hogar_id, codigo, creado_por) values (p_hogar_id, v_codigo, auth.uid());
  return v_codigo;
end;
$$;
grant execute on function public.crear_invitacion_hogar(uuid) to authenticated;

-- Unirse a un hogar con un código de invitación. security definer porque
-- quien todavía no es miembro no puede leer hogar_invitaciones por RLS.
create or replace function public.unirse_a_hogar_con_codigo(p_codigo text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_hogar_id uuid;
begin
  if exists (select 1 from hogar_miembros where user_id = auth.uid()) then
    raise exception 'Ya perteneces a un hogar. Sal de él antes de unirte a otro.';
  end if;

  select hogar_id into v_hogar_id
  from hogar_invitaciones
  where codigo = upper(trim(p_codigo)) and used_at is null;

  if v_hogar_id is null then
    raise exception 'Código de invitación no válido o ya usado';
  end if;

  insert into hogar_miembros (hogar_id, user_id, rol) values (v_hogar_id, auth.uid(), 'miembro');

  update hogar_invitaciones set usado_por = auth.uid(), used_at = now()
  where codigo = upper(trim(p_codigo));

  return v_hogar_id;
end;
$$;
grant execute on function public.unirse_a_hogar_con_codigo(text) to authenticated;
