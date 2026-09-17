# Proyecto_Comidas

App personal de gestión de comidas: registro de platos, calorías y balance nutritivo, generación automática de menú semanal según necesidades calóricas (macros) y lista de la compra editable (ajuste de ingredientes/despensa). Incluye hogares compartidos (pareja/familia) y batch cooking.

La app se muestra a los usuarios como **"Foodganizer"** (título, PWA, manifest) — "Proyecto_Comidas" es solo el nombre de la carpeta/repo, no se ha renombrado.

- Tier: 2 (app personal)
- Stack: HTML único + React (CDN) + Supabase

## Documentación
- @docs/architecture.md — decisiones de arquitectura y estructura técnica
- @docs/decisions.md — registro de decisiones (ADR ligero)
- @docs/backlog.md — funcionalidades pendientes, sin priorizar por sprint
- @docs/sprint.md — sprint actual y su estado

## Comandos
- `/sprint-status` — estado del sprint actual
- `/next-task` — próxima tarea pendiente
- `/commit` — commit siguiendo convención del proyecto
- `/idea` — capturar ideas nuevas

## NO hacer
- No añadir backend/framework adicional sin discutirlo antes (el stack es HTML único + React CDN + Supabase).
- No mezclar refactors con features en el mismo commit.
- No commitear ni hacer push sin que se pida explícitamente.
- No hardcodear claves de Supabase; usar variables de entorno / config no versionada.
