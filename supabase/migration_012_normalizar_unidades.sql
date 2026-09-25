-- Migración 012: normaliza unidades ya guardadas a las unidades base introducidas
-- en la app (g, ml, ud, cucharada, cucharadita, pizca), convirtiendo kg->g y l->ml.
--
-- Ejecutar una vez en el SQL Editor de Supabase.

create or replace function _mig012_unidad(unidad_original text) returns text as $$
  select case lower(trim(unidad_original))
    when 'g' then 'g' when 'gr' then 'g' when 'gramo' then 'g' when 'gramos' then 'g'
    when 'kg' then 'g' when 'kilo' then 'g' when 'kilos' then 'g' when 'kilogramo' then 'g' when 'kilogramos' then 'g'
    when 'ml' then 'ml' when 'mililitro' then 'ml' when 'mililitros' then 'ml'
    when 'l' then 'ml' when 'lt' then 'ml' when 'litro' then 'ml' when 'litros' then 'ml'
    when 'ud' then 'ud' when 'uds' then 'ud' when 'u' then 'ud' when 'unidad' then 'ud' when 'unidades' then 'ud'
    when 'cucharada' then 'cucharada' when 'cucharadas' then 'cucharada' when 'cda' then 'cucharada' when 'cdas' then 'cucharada'
    when 'cucharadita' then 'cucharadita' when 'cucharaditas' then 'cucharadita' when 'cdta' then 'cucharadita' when 'cdtas' then 'cucharadita'
    when 'pizca' then 'pizca' when 'pizcas' then 'pizca'
    else lower(trim(unidad_original))
  end;
$$ language sql immutable;

create or replace function _mig012_factor(unidad_original text) returns numeric as $$
  select case lower(trim(unidad_original))
    when 'kg' then 1000 when 'kilo' then 1000 when 'kilos' then 1000 when 'kilogramo' then 1000 when 'kilogramos' then 1000
    when 'l' then 1000 when 'lt' then 1000 when 'litro' then 1000 when 'litros' then 1000
    else 1
  end;
$$ language sql immutable;

-- Cast defensivo: los ingredientes de platos guardaban la cantidad como texto libre,
-- así que puede haber comas decimales ("1,2") o valores no numéricos sueltos.
create or replace function _mig012_to_numeric(v text) returns numeric as $$
begin
  return nullif(trim(replace(v, ',', '.')), '')::numeric;
exception when others then
  return 0;
end;
$$ language plpgsql immutable;

update despensa
set cantidad = round(cantidad * _mig012_factor(unidad), 2),
    unidad = _mig012_unidad(unidad);

update lista_compra
set cantidad = round(cantidad * _mig012_factor(unidad), 2),
    unidad = _mig012_unidad(unidad);

update platos
set ingredientes = (
  select jsonb_agg(
    jsonb_build_object(
      'nombre', elem->>'nombre',
      'cantidad', round(coalesce(_mig012_to_numeric(elem->>'cantidad'), 0) * _mig012_factor(elem->>'unidad'), 2),
      'unidad', _mig012_unidad(elem->>'unidad')
    )
  )
  from jsonb_array_elements(ingredientes) elem
)
where ingredientes is not null and jsonb_array_length(ingredientes) > 0;

drop function _mig012_unidad(text);
drop function _mig012_factor(text);
drop function _mig012_to_numeric(text);

-- Nota: unidades que no encajen en ninguna variante conocida (p. ej. "bote", "paquete")
-- se dejan tal cual (en minúsculas) — no hay forma automática de mapearlas a la unidad base.
-- Revísalas a mano si el dato te importa para el descuento de despensa/lista de la compra.
