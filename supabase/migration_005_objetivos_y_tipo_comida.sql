-- Migración 005: objetivos diarios de macros (perfiles) y tipo de comida
-- de cada plato (comida/cena/ambas), para el menú semanal automático.
-- Ejecutar una vez en el SQL Editor de Supabase.

alter table perfiles
  add column objetivo_calorias numeric,
  add column objetivo_proteinas_g numeric,
  add column objetivo_carbohidratos_g numeric,
  add column objetivo_grasas_g numeric;

alter table platos
  add column tipo_comida text not null default 'ambas' check (tipo_comida in ('comida', 'cena', 'ambas'));
