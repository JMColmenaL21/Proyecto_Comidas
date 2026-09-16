# Arquitectura — Proyecto_Comidas

## Stack
- Frontend: HTML único + React vía CDN (sin build step)
- Backend/datos: Supabase (Postgres + Auth + API)

## Estructura
_Pendiente de definir según avance el desarrollo._

## Modelo de datos

Definido en `supabase/schema.sql`. Todas las tablas son por usuario (RLS por `user_id = auth.uid()`); `platos` es por usuario por ahora, con posibilidad de hacerlo global más adelante.

- **`platos`**: recetas (ingredientes, calorías/macros por ración, `raciones_por_defecto`)
- **`lotes_cocinados`**: soporte de batch cooking — cada vez que se cocina un plato se crea un lote con `raciones_totales`/`raciones_restantes` y si queda `congelado`; se descuenta al consumir
- **`registro_comidas`**: comidas consumidas, opcionalmente ligadas a un lote
- **`despensa`**: inventario de ingredientes disponibles
- **`menu_semanal`**: menú generado, con `comensales` (determina raciones necesarias por comida)
- **`lista_compra`**: derivada de un menú (o manual)

### Batch cooking
El usuario cocina varias raciones de un plato de una vez (ej. 4 raciones de lentejas para 2 comensales → 2 se consumen, 2 quedan congeladas). Al generar el menú/lista de la compra semanal, se debe comprobar primero `lotes_cocinados` con `raciones_restantes > 0 AND congelado = true`: esas raciones cubren comidas sin necesidad de cocinar ni comprar ingredientes nuevos esa semana.

## Notas técnicas
_Añadir aquí decisiones de arquitectura relevantes a medida que se tomen (ver también docs/decisions.md)._
