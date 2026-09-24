# Backlog — Proyecto_Comidas

Funcionalidades pendientes, sin priorizar por sprint.

- [x] Registro de platos (ingredientes, calorías, macros) — incluye feed de platos de otros usuarios y "guardar en mis platos"
- [x] Gestión de despensa/inventario de ingredientes
- [x] Menú semanal (selección manual de platos por día/comida-cena)
- [x] Lista de la compra editable (derivada del menú, restando lo que ya hay en despensa)
- [x] Autenticación de usuario (Supabase Auth) — registro con usuario+email+contraseña, login con usuario o email
- [ ] Registro diario de comidas (sin sección propia todavía)
- [ ] Cálculo de balance calórico/macros diario
- [ ] Generación automática de menú semanal según necesidades calóricas (hoy es selección manual)
- [x] Hogares compartidos (despensa/menú/lista de la compra entre miembros de un hogar)
- [x] Despensa se descuenta al marcar una comida del menú como hecha (checklist por día/turno; antes solo se leía para la lista de la compra)
- [x] Batch cooking (`lotes_cocinados`) compartido por hogar, con UI ("Platos preparados" en Despensa), conteo real semana a semana (desaparece al llegar a 0) e integración con menú/lista de la compra
- [x] Foto + receta rápida en `platos` — al subir un plato, poder adjuntar una foto y una breve descripción de preparación, para darle más personalidad a cada plato del feed

## Ideas de monetización (sin decidir, ver `sprint.md`/`decisions.md` cuando se retome)

Contexto: plan de comprar dominios propios (.es/.com) para emails de confirmación (`noreply@foodganizer.es`) y salir del hosting público de GitHub Pages.

- Freemium por hogar (no por usuario, encaja con el modelo de datos actual): gratis con límites, premium desbloquea generación automática de menú, historial ilimitado, miembros de hogar ilimitados, exportar lista de compra
- Add-on de pago para generación automática de menú si acaba usando IA (coste variable por llamada, límite en plan gratis)
- Afiliación en la lista de la compra (enlaces a supermercados online)
- B2B: cuentas para nutricionistas/dietistas gestionando varios hogares/clientes
- Pago único "lifetime" para early adopters, para validar disposición a pagar antes de montar suscripción recurrente

Orden sugerido: lifetime early-adopter (al tener dominio propio) → freemium por hogar si hay tracción → IA como upsell. Afiliación y B2B, más adelante.
