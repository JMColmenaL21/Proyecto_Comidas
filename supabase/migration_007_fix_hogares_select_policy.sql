-- Migración 007: arregla la política de SELECT de "hogares".
--
-- Bug: al crear un hogar, crear_hogar() hace
--   insert into hogares (...) returning id into v_id;
-- y Postgres, para poder devolver esa fila (RETURNING), también exige que
-- pase la política de SELECT de la tabla. La política original solo dejaba
-- ver un hogar a quien ya fuera miembro (vía hogar_miembros), pero en ese
-- instante el creador todavía no es miembro de su propio hogar recién
-- creado (esa fila se inserta en la siguiente sentencia de la función) —
-- así que el RETURNING fallaba con "new row violates row-level security
-- policy for table hogares", aunque el usuario estuviera bien autenticado.
--
-- Arreglo: la política de SELECT también deja ver el hogar a quien lo creó
-- (created_by = auth.uid()), no solo a los miembros actuales.
--
-- Ejecutar una vez en el SQL Editor de Supabase (ya con migration_006
-- aplicada).

drop policy "hogares_select_miembro" on hogares;

create policy "hogares_select_miembro" on hogares for select using (
  created_by = auth.uid() or id in (select public.hogares_de(auth.uid()))
);
