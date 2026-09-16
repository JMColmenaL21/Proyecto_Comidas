-- Migración 004: perfil creado automáticamente al registrarse (trigger en
-- auth.users, no depende de que el usuario inicie sesión primero con email)
-- y rastreo persistente de "ya guardado" en el feed de platos.
-- Ejecutar una vez en el SQL Editor de Supabase.

alter table platos add column origen_plato_id uuid references platos(id) on delete set null;

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
