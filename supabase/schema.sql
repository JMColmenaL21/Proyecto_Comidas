-- Proyecto_Comidas — modelo de datos inicial
-- Todas las tablas son por usuario (RLS por user_id = auth.uid())

create extension if not exists "pgcrypto";

-- Perfiles: nombre visible (único sin distinguir mayúsculas) para mostrar
-- autoría en el feed de platos.
create table perfiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text not null check (char_length(trim(nombre)) between 2 and 30),
  objetivo_calorias numeric,
  objetivo_proteinas_g numeric,
  objetivo_carbohidratos_g numeric,
  objetivo_grasas_g numeric,
  created_at timestamptz not null default now()
);
create unique index perfiles_nombre_unique_idx on perfiles (lower(nombre));

-- Recetas/platos. Visibles por todos los usuarios (feed para descubrir y
-- copiar platos de otros), pero solo el dueño (user_id) puede editarlos o
-- borrarlos.
create table platos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references perfiles(id) on delete cascade,
  nombre text not null,
  ingredientes jsonb not null default '[]', -- [{nombre, cantidad, unidad}]
  calorias_racion numeric,
  proteinas_g numeric,
  carbohidratos_g numeric,
  grasas_g numeric,
  raciones_por_defecto integer not null default 1,
  origen_plato_id uuid references platos(id) on delete set null, -- si viene de "guardar en mis platos", de qué plato original (para no duplicar al refrescar)
  tipo_comida text not null default 'ambas' check (tipo_comida in ('comida', 'cena', 'ambas')),
  created_at timestamptz not null default now()
);

-- Cada vez que se cocina un plato (batch cooking), se registra un lote
-- con las raciones que salen. Las que no se consumen en el momento
-- quedan disponibles (congeladas o no) para semanas futuras.
create table lotes_cocinados (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  plato_id uuid not null references platos(id) on delete cascade,
  fecha_cocinado date not null default current_date,
  raciones_totales integer not null check (raciones_totales > 0),
  raciones_restantes integer not null check (raciones_restantes >= 0),
  congelado boolean not null default false,
  fecha_caducidad_estimada date,
  created_at timestamptz not null default now(),
  constraint raciones_restantes_no_supera_totales check (raciones_restantes <= raciones_totales)
);

-- Registro de comidas consumidas. Si viene de un lote (batch cooking),
-- se referencia lote_id y se descuenta raciones_restantes del lote.
create table registro_comidas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  lote_id uuid references lotes_cocinados(id) on delete set null,
  plato_id uuid references platos(id) on delete set null,
  fecha date not null default current_date,
  tipo_comida text not null check (tipo_comida in ('desayuno', 'comida', 'cena', 'snack')),
  raciones numeric not null default 1,
  created_at timestamptz not null default now()
);

-- Despensa/inventario de ingredientes disponibles
create table despensa (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  ingrediente text not null,
  cantidad numeric not null,
  unidad text not null,
  updated_at timestamptz not null default now(),
  unique (user_id, ingrediente, unidad)
);

-- Menú semanal generado. comensales determina cuántas raciones
-- necesita cada comida al generar el menú y la lista de la compra.
create table menu_semanal (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  fecha_inicio date not null,
  comensales integer not null default 1 check (comensales > 0),
  dias jsonb not null default '{}', -- {"lunes": {"comida": plato_id, "cena": plato_id}, ...}
  created_at timestamptz not null default now()
);

-- Lista de la compra, derivada de un menú (o manual si menu_id es null)
create table lista_compra (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  menu_id uuid references menu_semanal(id) on delete set null,
  ingrediente text not null,
  cantidad numeric not null,
  unidad text not null,
  comprado boolean not null default false,
  created_at timestamptz not null default now()
);

-- RLS: cada usuario solo ve y modifica sus propios datos, salvo platos
-- (visible por todos, editable solo por su dueño) y perfiles (ver arriba).
alter table perfiles enable row level security;
alter table platos enable row level security;
alter table lotes_cocinados enable row level security;
alter table registro_comidas enable row level security;
alter table despensa enable row level security;
alter table menu_semanal enable row level security;
alter table lista_compra enable row level security;

create policy "perfiles_select_authenticated" on perfiles for select using (auth.role() = 'authenticated');
create policy "perfiles_insert_own" on perfiles for insert with check (auth.uid() = id);
create policy "perfiles_update_own" on perfiles for update using (auth.uid() = id) with check (auth.uid() = id);

create policy "platos_select_authenticated" on platos for select using (auth.role() = 'authenticated');
create policy "platos_insert_own" on platos for insert with check (auth.uid() = user_id);
create policy "platos_update_own" on platos for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "platos_delete_own" on platos for delete using (auth.uid() = user_id);

create policy "lotes_cocinados_own" on lotes_cocinados for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "registro_comidas_own" on registro_comidas for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "despensa_own" on despensa for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "menu_semanal_own" on menu_semanal for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "lista_compra_own" on lista_compra for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Registro en un solo paso (usuario + email + contraseña) y login con
-- usuario o email: ver migration_003_registro_unificado.sql para las
-- funciones nombre_en_uso() y email_for_username().

-- Perfil creado automáticamente al registrarse (no depende de que el
-- usuario inicie sesión primero con email para poder usar login por usuario).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  if new.raw_user_meta_data ->> 'nombre' is not null then
    insert into public.perfiles (id, nombre)
    values (new.id, new.raw_user_meta_data ->> 'nombre');
  end if;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
