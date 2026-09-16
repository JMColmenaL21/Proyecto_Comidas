# Sprint actual — Proyecto_Comidas

## Estado
En curso.

## Objetivo del sprint
Tener la app navegable localmente (HTML único + React) con las secciones base, lista para conectar Supabase en cuanto exista la cuenta.

## Tareas
- [x] Definir modelo de datos inicial en Supabase (`supabase/schema.sql`)
- [x] Montar esqueleto HTML + React (CDN)
- [x] Conectar Supabase (auth + tabla de platos) — cuenta creada, schema cargado, `config.js` conectado, login/registro con Supabase Auth funcionando (SMTP propio vía Gmail dedicado, ver `decisions.md`)
- [x] CRUD de `platos` (con feed de otros usuarios y "guardar en mis platos")
- [x] Despensa (CRUD privado)
- [x] Menú semanal (selección manual por día/comida-cena)
- [x] Lista de la compra (generada desde un menú, resta despensa, editable, añadir a mano)

Prototipo con las 4 secciones funcionales listo para probar de extremo a extremo. Pendiente de prueba manual del usuario en el navegador.

## Pendientes conocidos (no bloquean, arreglar más adelante)
- Los emails de confirmación pueden caer en spam (SMTP propio sin dominio verificado, reputación de envío baja).
- El enlace de confirmación de email redirige a `http://localhost:3000` (no existe, la app es un HTML local sin servidor) → tras confirmar, el usuario ve una página de error del navegador antes de volver a abrir la app manualmente. No rompe la confirmación en sí.

## Antes de "lanzarlo" (último paso, pendiente hasta que el usuario lo pida)
- Borrar todos los usuarios/perfiles/platos de prueba: `delete from auth.users;` en el SQL Editor de Supabase (cascada a todo lo demás). Decisión explícita del usuario: no ejecutar todavía.
