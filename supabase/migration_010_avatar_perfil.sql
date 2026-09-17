-- Migración 010: avatar de perfil (emoji elegido de una lista acotada con
-- temática de comida). Opcional; si no se elige ninguno, se sigue mostrando
-- la inicial del nombre en el círculo del perfil.
--
-- Ejecutar una vez en el SQL Editor de Supabase.

alter table perfiles add column avatar text;
