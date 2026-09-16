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
