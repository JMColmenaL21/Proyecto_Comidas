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

## Despliegue
App publicada en GitHub Pages: https://jmcolmenal21.github.io/Proyecto_Comidas/ (repo público `JMColmenaL21/Proyecto_Comidas`, deploy automático con cada `git push` a `main`). PWA instalable desde el móvil ("Añadir a pantalla de inicio").

## Pendientes conocidos (no bloquean, arreglar más adelante)
- Los emails de confirmación pueden caer en spam (SMTP propio sin dominio verificado, reputación de envío baja).
- Redirección tras confirmar email: pendiente de actualizar Site URL/Redirect URLs en Supabase a la URL de GitHub Pages (antes apuntaba a `localhost:3000`) — instrucciones dadas, pendiente de que el usuario lo aplique.

## Antes de "lanzarlo" (último paso, pendiente hasta que el usuario lo pida)
- Borrar todos los usuarios/perfiles/platos de prueba: `delete from auth.users;` en el SQL Editor de Supabase (cascada a todo lo demás). Decisión explícita del usuario: no ejecutar todavía.
