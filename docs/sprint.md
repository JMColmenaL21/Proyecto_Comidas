# Sprint actual — Proyecto_Comidas

## Estado
En curso.

## Siguiente al retomar (hacer esto primero)
- [ ] Probar en el navegador (local o refrescando la web) que la fila de ingredientes del formulario de plato se ve bien: se arregló un CSS (`.ingredient-row select`) que se rompió al cambiar la unidad de texto libre a desplegable — ver "Unidades e ingredientes estandarizados" más abajo. Cambio commiteado en local, **sin pushear** hasta confirmar.
- [ ] Si se ve bien: `git push`. Si no: seguir ajustando antes de pushear.
- [ ] Borrar en Supabase → Authentication → Users el usuario de prueba sin confirmar `playground-test-foodganizer+...@example.com` (creado al intentar una prueba automática end-to-end, quedó sin confirmar por email).

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
- [x] Fase 0b: migración `hogares`/`hogar_miembros`/`hogar_invitaciones`, RLS y funciones (`crear_hogar`, `crear_invitacion_hogar`, `unirse_a_hogar_con_codigo`) — migración `supabase/migration_006_hogares_compartidos.sql` ejecutada
- [x] Fase 0c: UI "Mi hogar" en el desplegable (crear/unirse por código/ver miembros/salir) y `hogar_id` en los inserts de despensa, menú y lista de la compra + autor visible en despensa/lista
- [x] Fase 1: despensa se descuenta al marcar una comida del menú como hecha (checklist por día/turno en Menú semanal). Disparador elegido: marcar manualmente cada comida individual, no toda la semana de golpe ni automático por fecha — ver `decisions.md`. Migración `supabase/migration_008_comidas_hechas.sql` ejecutada
- [x] Fase 2: batch cooking compartido — subtab "Platos preparados" en Despensa (CRUD de lotes), `lotes_cocinados` con `hogar_id`, checklist del menú consume primero lotes disponibles (antes que despensa) y la generación de lista de la compra resta la cobertura de lotes antes de calcular ingredientes. Migración `supabase/migration_009_lotes_cocinados_hogar.sql` ejecutada

## Foto + receta rápida en platos
- [x] Migración `supabase/migration_011_foto_receta_plato.sql` (columnas `foto_url`/`receta_rapida` + bucket `fotos-platos` con políticas RLS) — ejecutada en Supabase SQL Editor
- [x] Subida de foto y receta rápida en `PlatoForm`, con preview y borrado del archivo viejo al reemplazar
- [x] Mostrar foto y receta en `PlatoCard` (tarjetas) y `PlatoListRow` (lista)
- [x] Borrar el archivo del bucket al eliminar un plato; copiar foto/receta al "guardar en mis platos"
- [ ] Probar manualmente el flujo completo (subir foto + receta a un plato real) — pendiente, ver "Siguiente al retomar"

## Unidades e ingredientes estandarizados
- [x] Unidades cerradas a desplegable (g/kg/ml/l/ud/cucharada/cucharadita/pizca); kg/l se convierten a g/ml al guardar
- [x] Nombres de ingrediente normalizados (trim + capitalización) + diccionario de alias (`ALIAS_INGREDIENTES`) para variantes de plural/mayúsculas
- [x] Cantidades redondeadas a 2 decimales; presentación agrupada en kg/l cuando el valor es grande
- [x] Migración `supabase/migration_012_normalizar_unidades.sql` (despensa, lista de la compra, ingredientes de platos) — ejecutada
- [ ] Fix de CSS (`.ingredient-row select`) tras probarlo — ver "Siguiente al retomar", pendiente de confirmar visualmente y pushear

## Despliegue
App publicada en GitHub Pages: https://jmcolmenal21.github.io/Proyecto_Comidas/ (repo público `JMColmenaL21/Proyecto_Comidas`, deploy automático con cada `git push` a `main`). PWA instalable desde el móvil ("Añadir a pantalla de inicio").

## Pendientes conocidos (no bloquean, arreglar más adelante)
- Los emails de confirmación pueden caer en spam (SMTP propio sin dominio verificado, reputación de envío baja).
- [x] Redirección tras confirmar email: Site URL y Redirect URLs configuradas en Supabase → Authentication → URL Configuration.

## Limpieza de datos de prueba
- [x] Usuarios/perfiles/platos de prueba borrados (`delete from auth.users;` en el SQL Editor de Supabase, cascada a todo lo demás).
