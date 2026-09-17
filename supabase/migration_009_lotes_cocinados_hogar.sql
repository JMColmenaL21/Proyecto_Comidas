-- Migración 009: batch cooking (lotes_cocinados) compartido por hogar,
-- igual que ya pasa con despensa/menu_semanal/lista_compra desde la
-- migración 006.
--
-- Ejecutar una vez en el SQL Editor de Supabase.

alter table lotes_cocinados add column hogar_id uuid references hogares(id) on delete set null;

drop policy "lotes_cocinados_own" on lotes_cocinados;
create policy "lotes_cocinados_own_o_hogar" on lotes_cocinados for all
  using (user_id = auth.uid() or hogar_id in (select public.hogares_de(auth.uid())))
  with check (user_id = auth.uid() or hogar_id in (select public.hogares_de(auth.uid())));
