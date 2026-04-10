select ep.tipo_unidade , ep.unidade , ep.cod_produto , ep.nome_produto , ep.categoria , ep.classe , ep.subclasse , ep.estoque_atual , ep.observacao , ep.qtd_movimentacao , ep.data_movimentacao , ep.fator_conversao , pc.m2 , pc.peso , pc.fabricante  from estoque_produtos ep 
left join produtos_completos pc on ep.unidade = pc.unidade and ep.cod_produto = pc.codigo_interno  
where ep.tipo_movimentacao = 'COMPRA'
and ep.unidade in ('VITORIA DE SANTO ANTAO', '4D Vidros', 'INBRAVIDROS', 'BRASILIA', 'Oazem', 'FORTALEZA', 'ALLGLASS TEMPERA', 'TEMPER PATOS', 'UBERVIDROS', 'Agreste Vidros', 'Alumiaco Recife', 'DVM PARAIBA', 'GM Maceio', 'GM Recife')
and ep.categoria ilike '%CHAPARIA%'
and ep.data_movimentacao >= '2025-03-01'