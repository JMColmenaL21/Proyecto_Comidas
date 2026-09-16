# Comidas

App personal (y familiar) de gestión de comidas: recetas, despensa, menú semanal y lista de la compra — con Supabase como backend y sin build step.

## Funcionalidades

- **Cuentas**: registro con usuario + email + contraseña, login con usuario o email. Cada usuario ve solo sus propios datos salvo lo indicado abajo.
- **Platos**: tus propias recetas (ingredientes, calorías/macros, raciones) y un feed para descubrir los platos de otros usuarios y guardarlos como copia propia editable. Cada plato se puede marcar como solo comida, solo cena, o ambas.
- **Despensa**: inventario privado de ingredientes disponibles.
- **Menú semanal**: elige manualmente un plato por día (comida/cena), o genera uno aleatorio que intenta ajustarse a tus objetivos diarios de calorías/macros (si los has definido).
- **Lista de la compra**: se genera a partir de un menú, restando automáticamente lo que ya tienes en la despensa. También se pueden añadir ítems a mano.
- Instalable como app en el móvil (PWA): añádela a la pantalla de inicio desde el navegador para que se abra a pantalla completa, como una app nativa.

## Stack

HTML único + React (vía CDN, sin build step) + Supabase (Postgres + Auth + API). Ver [`docs/architecture.md`](docs/architecture.md) y [`docs/decisions.md`](docs/decisions.md) para el porqué de estas decisiones.

## Poner en marcha tu propia instancia

1. Crea un proyecto en [supabase.com](https://supabase.com).
2. En el **SQL Editor** del proyecto, ejecuta en orden: `supabase/schema.sql` y luego cada `supabase/migration_*.sql` por número.
3. En **Project Settings → API**, copia la `Project URL` y la clave `anon public`.
4. Copia `config.example.js` como `config.js` y pega ahí esos dos valores.
5. (Opcional pero recomendado) Configura un SMTP propio en **Project Settings → Auth → SMTP Settings** — el proveedor de email integrado de Supabase está limitado a 2 emails/hora.
6. Abre `index.html` en el navegador (o `Iniciar Comidas.bat` en Windows).

`config.js` sí va commiteado en este repo porque hace falta en tiempo de ejecución para el despliegue público — la clave `anon` de Supabase está pensada para ir en el cliente; la seguridad real la da Row Level Security, no ocultar esa clave.

## Licencia

MIT — ver [`LICENSE`](LICENSE).
