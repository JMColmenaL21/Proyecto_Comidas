# Decisiones — Proyecto_Comidas

## 2026-09-14 — Stack inicial
Stack elegido: HTML único + React (CDN) + Supabase.

**Por qué:** app personal, sin necesidad de build step ni backend propio; Supabase cubre auth y persistencia sin infraestructura adicional.

## 2026-09-14 — Modelo de datos: batch cooking y `platos` por usuario
- `platos` es por usuario (no global) por ahora; se deja la puerta abierta a hacerlo global si la app crece.
- Se añade `lotes_cocinados` para soportar batch cooking: registra raciones totales/restantes y si están congeladas, para que la generación de menú y lista de la compra descuente primero de lo ya cocinado antes de proponer cocinar/comprar más.
- `menu_semanal` incluye `comensales` para calcular raciones necesarias.

**Por qué:** el usuario cocina en batch (una vez por semana, varias raciones) y congela el sobrante; sin esto la generación automática de menú/compra ignoraría el stock congelado y generaría compras de más.

## 2026-09-16 — SMTP propio para emails de Auth (cuenta Gmail dedicada)
Supabase Auth usa SMTP propio en vez del servicio de email integrado (limitado a 2 emails/hora). Se usa una cuenta Gmail dedicada a la app (no la personal del usuario) con contraseña de aplicación, vía `smtp.gmail.com`.

**Por qué:** el servicio de email integrado de Supabase es demasiado limitado para uso familiar (varias personas registrándose). Se descartó Resend/Brevo por requerir crear cuenta en una plataforma adicional (Resend además restringe destinatarios sin dominio verificado); comprar un dominio propio se descartó por coste/complejidad para una app personal. Gmail con cuenta dedicada evita ambos problemas sin cuentas ni gastos extra.

**Pendiente de arreglar:** posible caída en spam (sin dominio verificado, reputación de envío baja) y el enlace de confirmación redirige a `http://localhost:3000` (no existe, la app no tiene servidor) — no bloquea el flujo pero da una página de error tras confirmar.

## 2026-09-17 — Hogares compartidos: código de invitación, no amistad genérica

Para que dos usuarios (p. ej. pareja) compartan despensa/menú/lista de la compra, se descartó un sistema genérico de "amigos" (solicitud/aceptar + compartir copias) a favor de un **hogar**: un grupo al que perteneces y cuyas filas de `despensa`, `menu_semanal` y `lista_compra` ven y editan todos sus miembros directamente (mismo dato, no una copia).

- Un usuario pertenece como máximo a un hogar a la vez (`hogar_miembros` tiene índice único por `user_id`) — evita tener que elegir "para qué hogar" al añadir algo.
- Unirse a un hogar es por **código de invitación** (6 caracteres, generado por un miembro ya dentro), no buscando directamente por nombre de usuario — así nadie se cuela en un hogar solo por adivinar o conocer el nombre de otro usuario.
- `platos` no participa del hogar: ya es visible por todos los usuarios autenticados (feed existente), así que un menú puede usar platos de cualquier miembro sin cambios ahí.
- `lotes_cocinados` y `registro_comidas` (batch cooking y consumo individual) se quedan fuera de este cambio por ahora — el consumo es individual y batch cooking todavía no tiene UI. Si en el futuro se comparte batch cooking a nivel de hogar, será una migración aparte con el mismo patrón (`hogar_id` + RLS).

**Por qué:** el caso de uso real (pareja que hace la misma compra y el mismo menú) es "somos el mismo dato", no "te mando una copia de mis datos" — un sistema de amistad con copias sería más trabajo y peor ajuste.

## 2026-09-17 — Disparador del descuento de despensa: marcar cada comida hecha

Se valoraron tres formas de disparar el descuento de despensa al consumir el menú: (A) marcar cada comida individual (día+turno) como hecha, (B) un botón único "marcar semana consumida" que descuenta todo de golpe, (C) automático por fecha (sin acción del usuario). Se eligió **A**.

- `menu_semanal.dias` (el plan: qué plato toca cada día/turno) no se toca. Se añade `menu_semanal.comidas_hechas jsonb`, por separado, con el estado de ejecución: `{"lunes": {"comida": {"hecho": true, "ajustes": [{"despensa_id": "...", "cantidad": 300}]}}}`.
- Al marcar: se resta de la despensa lo que haya disponible (nunca negativo) y se guarda la cantidad **real** restada de cada ingrediente (no la necesaria en teoría).
- Al desmarcar: se devuelve exactamente esa cantidad guardada, sin recalcular — evita descuadres si la despensa cambió mientras tanto (otro miembro del hogar editó algo).
- Este mismo disparador (marcar una comida como hecha) es el que usará el batch cooking compartido (Fase 2, ver `backlog.md`) para descontar raciones de lote.

**Por qué:** B es más simple de construir pero todo-o-nada (no distingue qué días se cumplieron según el plan). C parece cómodo (cero clics) pero asume que siempre se cocina exactamente lo planeado — en cuanto el usuario se desvía (come fuera, cambia de plato), genera datos incorrectos de forma silenciosa. A es el único que refleja lo que realmente pasó y el único que permite el conteo progresivo día a día que se pidió para el batch cooking de la Fase 2.

## 2026-09-17 — Batch cooking compartido (Fase 2)

- `lotes_cocinados` gana `hogar_id` (mismo patrón que despensa/menú/compra desde la migración 006); antes se dejó fuera a propósito, ahora se decide compartirlo también.
- UI: subtab "Platos preparados" dentro de Despensa (no una sección nueva en la navegación principal), con CRUD de lotes. Los lotes con `raciones_restantes = 0` se ocultan de la lista — no tiene sentido seguir mostrando algo agotado.
- Emparejamiento comida↔lote: por `plato_id` exacto (no por nombre ni por tipo de comida).
- Orden de consumo cuando hay varios lotes del mismo plato: primero el que caduca antes (`fecha_caducidad_estimada`), luego el más antiguo (`fecha_cocinado`) — evita que se estropee comida en el congelador mientras se usa la más reciente.
- No se distingue congelado/no congelado a la hora de cubrir una comida: cualquier lote con raciones disponibles cuenta, esté congelado o no (a diferencia de lo que decía la nota inicial en `architecture.md`, que solo mencionaba congelados).
- Reutiliza el disparador de la Fase 1 ("marcar comida hecha"): al marcar, se consumen primero raciones de lote y solo el resto sin cubrir se resta de la despensa; se guarda qué lote(s) y cuánta cantidad (`loteAjustes`) para poder desmarcar y devolver exacto, igual que ya se hace con los ajustes de despensa.
- La lista de la compra, al generarse, también resta la cobertura de lotes disponibles antes de calcular ingredientes — comparte el total disponible de un plato entre sus distintas apariciones en la semana (por orden de día). Es solo una estimación de cara a la compra: no descuenta nada real, el descuento real solo ocurre al marcar una comida como hecha.
