-- Migración 011: foto y receta rápida en platos.
--
-- Ejecutar una vez en el SQL Editor de Supabase.

alter table platos add column foto_url text;
alter table platos add column receta_rapida text;

-- Bucket público de lectura para las fotos de platos.
-- Path de cada archivo: <user_id>/<uuid>.<ext>
insert into storage.buckets (id, name, public)
values ('fotos-platos', 'fotos-platos', true)
on conflict (id) do nothing;

create policy "Lectura pública de fotos de platos"
on storage.objects for select
using (bucket_id = 'fotos-platos');

create policy "Usuarios suben sus propias fotos de platos"
on storage.objects for insert
with check (bucket_id = 'fotos-platos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Usuarios actualizan sus propias fotos de platos"
on storage.objects for update
using (bucket_id = 'fotos-platos' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Usuarios borran sus propias fotos de platos"
on storage.objects for delete
using (bucket_id = 'fotos-platos' and (storage.foldername(name))[1] = auth.uid()::text);
