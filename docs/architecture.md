# Arquitectura — Proyecto_Comidas

## Stack
- Frontend: HTML único + React vía CDN (sin build step)
- Backend/datos: Supabase (Postgres + Auth + API)

## Estructura
_Pendiente de definir según avance el desarrollo._

## Modelo de datos

Definido en `supabase/schema.sql`. Todas las tablas son por usuario (RLS por `user_id = auth.uid()`); `platos` es por usuario por ahora, con posibilidad de hacerlo global más adelante.

- **`platos`**: recetas (ingredientes, calorías/macros por ración, `raciones_por_defecto`)
- **`lotes_cocinados`**: soporte de batch cooking — cada vez que se cocina un plato se crea un lote con `raciones_totales`/`raciones_restantes` y si queda `congelado`; se descuenta al consumir. Compartido por hogar igual que despensa/menú/compra (`hogar_id`)
- **`registro_comidas`**: comidas consumidas, opcionalmente ligadas a un lote
- **`despensa`**: inventario de ingredientes disponibles
- **`menu_semanal`**: menú generado, con `comensales` (determina raciones necesarias por comida)
- **`lista_compra`**: derivada de un menú (o manual)
- **`hogares`** / **`hogar_miembros`** / **`hogar_invitaciones`**: hogar compartido entre usuarios (p. ej. pareja). Un usuario pertenece como máximo a un hogar. `despensa`, `menu_semanal` y `lista_compra` tienen `hogar_id` opcional: si está informado, todos los miembros del hogar ven y editan esas filas (RLS), no solo su creador (`user_id` sigue indicando autoría)

### Batch cooking
El usuario cocina varias raciones de un plato de una vez (ej. 4 raciones de lentejas para 2 comensales → 2 se consumen, 2 quedan congeladas). UI en Despensa → subtab "Platos preparados" (CRUD de lotes; los que llegan a `raciones_restantes = 0` desaparecen de la vista).

- **Lista de la compra**: al generar, por cada plato del menú se resta primero de `lotes_cocinados` (cualquiera con `raciones_restantes > 0`, no solo congelados) lo que cubra esas raciones, compartiendo el total disponible entre las distintas apariciones del plato en la semana; solo lo que quede sin cubrir genera ingredientes en la lista.
- **Marcar comida hecha** (menú semanal, ver Fase 1 en `sprint.md`): mismo disparador que descuenta despensa. Al marcar, primero se consumen raciones de lote (las que caducan antes, luego las más antiguas), y solo el resto se resta de la despensa. Se guarda `loteAjustes` (qué lote y cuánta cantidad) junto a `ajustes` de despensa en `comidas_hechas`, para poder desmarcar y devolver exactamente esas raciones.

## Notas técnicas
_Añadir aquí decisiones de arquitectura relevantes a medida que se tomen (ver también docs/decisions.md)._
