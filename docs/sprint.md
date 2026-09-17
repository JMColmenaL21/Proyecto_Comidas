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

## Hogares compartidos (en curso, por fases — ver `decisions.md` y `backlog.md`)
- [x] Fase 0a: perfil con desplegable en el header (nombre, email, objetivos diarios movidos aquí, salir)
- [x] Fase 0b: migración `hogares`/`hogar_miembros`/`hogar_invitaciones`, RLS y funciones (`crear_hogar`, `crear_invitacion_hogar`, `unirse_a_hogar_con_codigo`) — **pendiente ejecutar en Supabase SQL Editor**: `supabase/migration_006_hogares_compartidos.sql`
- [x] Fase 0c: UI "Mi hogar" en el desplegable (crear/unirse por código/ver miembros/salir) y `hogar_id` en los inserts de despensa, menú y lista de la compra + autor visible en despensa/lista
- [x] Fase 1: despensa se descuenta al marcar una comida del menú como hecha (checklist por día/turno en Menú semanal). Disparador elegido: marcar manualmente cada comida individual, no toda la semana de golpe ni automático por fecha — ver `decisions.md`. Migración: `supabase/migration_008_comidas_hechas.sql` — **pendiente ejecutar en Supabase SQL Editor**
- [x] Fase 2: batch cooking compartido — subtab "Platos preparados" en Despensa (CRUD de lotes), `lotes_cocinados` con `hogar_id`, checklist del menú consume primero lotes disponibles (antes que despensa) y la generación de lista de la compra resta la cobertura de lotes antes de calcular ingredientes. Migración: `supabase/migration_009_lotes_cocinados_hogar.sql` — **pendiente ejecutar en Supabase SQL Editor**

## Despliegue
App publicada en GitHub Pages: https://jmcolmenal21.github.io/Proyecto_Comidas/ (repo público `JMColmenaL21/Proyecto_Comidas`, deploy automático con cada `git push` a `main`). PWA instalable desde el móvil ("Añadir a pantalla de inicio").

## Pendientes conocidos (no bloquean, arreglar más adelante)
- Los emails de confirmación pueden caer en spam (SMTP propio sin dominio verificado, reputación de envío baja).
- Redirección tras confirmar email: el código ya manda `emailRedirectTo` con la URL real de la app (antes no se especificaba y caía en el valor por defecto de Supabase, `localhost:3000`). **Falta un paso manual que no se puede hacer por API**: añadir esa URL en Supabase → Authentication → URL Configuration → Site URL y Redirect URLs, si no, Supabase la ignora y sigue usando el valor por defecto.

## Antes de "lanzarlo" (último paso, pendiente hasta que el usuario lo pida)
- Borrar todos los usuarios/perfiles/platos de prueba: `delete from auth.users;` en el SQL Editor de Supabase (cascada a todo lo demás). Decisión explícita del usuario: no ejecutar todavía.
