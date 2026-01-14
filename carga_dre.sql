select
	eg.unidade,
    eg.carga,
    eg.rota,
    TO_CHAR(data_hora_entregue::DATE,'YYYY-MM-DD') as data, 
    eg.nome_produto, 
    CASE
        WHEN eg.coes = 'ENGENHARIA PADRÃO'::text THEN 'ENGENHARIA PADRÃO'::text
        ELSE eg.categoria_produto
    END AS categoria,
    round(sum(eg.metragem_entregue::numeric), 2) AS m2,
    round(sum(eg.peso_entregue::numeric), 2) AS peso,
    round(sum(eg.valor_entregue+COALESCE(acrescimo,0)), 2) AS valor,
    round(sum(eg.custo_entregue), 2) AS custo from entregas_geral eg
where unidade = 'VITORIA DE SANTO ANTAO' and data_hora_entregue::date >= '2025-12-18' and data_hora_entregue::date <= '2025-12-31' and eg.carga is not null
GROUP BY eg.unidade, eg.carga, eg.coes, TO_CHAR(data_hora_entregue::DATE,'YYYY-MM-DD'), eg.categoria_produto, eg.rota, eg.nome_produto
order by eg.carga desc