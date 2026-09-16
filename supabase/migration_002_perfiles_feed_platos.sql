-- Migración 002: perfiles (nombre único) + platos visibles por todos (feed)
-- Ejecutar una vez en el SQL Editor de Supabase.

-- Perfiles: nombre visible (único sin distinguir mayúsculas) para mostrar
-- autoría en el feed de platos.
create table perfiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text not null check (char_length(trim(nombre)) between 2 and 30),
  created_at timestamptz not null default now()
);
create unique index perfiles_nombre_unique_idx on perfiles (lower(nombre));

alter table perfiles enable row level security;
create policy "perfiles_select_authenticated" on perfiles for select using (auth.role() = 'authenticated');
create policy "perfiles_insert_own" on perfiles for insert with check (auth.uid() = id);
create policy "perfiles_update_own" on perfiles for update using (auth.uid() = id) with check (auth.uid() = id);

-- Platos: visibles por todos los usuarios autenticados (feed), pero
-- editables/borrables solo por su dueño. user_id pasa a referenciar
-- perfiles (en vez de auth.users) para poder unir y mostrar el autor.
alter table platos drop constraint platos_user_id_fkey;
alter table platos add constraint platos_user_id_fkey foreign key (user_id) references perfiles(id) on delete cascade;

drop policy "platos_own" on platos;
create policy "platos_select_authenticated" on platos for select using (auth.role() = 'authenticated');
create policy "platos_insert_own" on platos for insert with check (auth.uid() = user_id);
create policy "platos_update_own" on platos for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "platos_delete_own" on platos for delete using (auth.uid() = user_id);
