-- Migración 008: la despensa se descuenta al marcar una comida del menú
-- como "hecha".
--
-- comidas_hechas guarda, por día y turno, si esa comida ya se marcó como
-- hecha y EXACTAMENTE cuánto se restó de cada ingrediente de la despensa
-- (no solo un booleano). Así, al desmarcarla, se puede devolver la cantidad
-- exacta sin tener que recalcular — evita descuadres si la despensa cambió
-- mientras tanto (p. ej. alguien del hogar editó una cantidad a mano).
--
-- Forma: {"lunes": {"comida": {"hecho": true, "ajustes": [{"despensa_id": "...", "cantidad": 300}]}}}
--
-- No se toca "dias" (sigue siendo solo el plan: qué plato toca cada
-- día/turno); comidas_hechas es la ejecución/consumo real, por separado.
--
-- Ejecutar una vez en el SQL Editor de Supabase.

alter table menu_semanal add column comidas_hechas jsonb not null default '{}';
