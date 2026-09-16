-- Migración 003: registro en un solo paso (usuario + email + contraseña)
-- y login con usuario o email. Ejecutar una vez en el SQL Editor de Supabase.

-- Comprobar si un nombre de usuario ya está en uso, para validarlo en el
-- formulario de registro (funciona incluso sin sesión iniciada).
create or replace function public.nombre_en_uso(p_nombre text)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (select 1 from perfiles where lower(nombre) = lower(p_nombre));
$$;
grant execute on function public.nombre_en_uso(text) to anon, authenticated;

-- Resolver el email asociado a un nombre de usuario, para poder iniciar
-- sesión con usuario en vez de email (Supabase Auth solo admite email).
-- Solo devuelve el email de una coincidencia exacta de nombre, no permite
-- listar ni enumerar cuentas.
create or replace function public.email_for_username(p_nombre text)
returns text
language sql
security definer
set search_path = public, auth
as $$
  select u.email
  from perfiles p
  join auth.users u on u.id = p.id
  where lower(p.nombre) = lower(p_nombre)
  limit 1;
$$;
grant execute on function public.email_for_username(text) to anon;
