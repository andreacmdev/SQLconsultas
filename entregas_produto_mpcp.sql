SELECT 
    eg.tipo_unidade,
    eg.unidade,
    eg.tipo_produto,
    date_trunc('month', eg.data_hora_entregue) AS mes_ref,  -- 🔹 mês de referência
    eg.categoria_produto,
    eg.classe_produto,
    eg.sub_classe_produto,
    eg.cod_produto,
    eg.nome_produto,
    SUM(eg.qtd_entregue) AS qtd_entregue_total,
    SUM(REPLACE(eg.peso_entregue, ',', '.')::numeric) AS peso_entregue_total,
    SUM(REPLACE(eg.metragem_entregue, ',', '.')::numeric) AS metragem_entregue_total,
    MAX(eg.custo_unitario_produto) AS custo_unitario_produto,
    MAX(mcpc.espessura_mm) AS espessura_mm,
    mcpc.hva,
    MAX(mcpc.material) AS material,
    MAX(mcpc.tipo_de_vidro) AS tipo_de_vidro
FROM entregas_geral eg
LEFT JOIN mapeamento_categoria_produtos_completo mcpc
    ON eg.categoria_produto   = mcpc.categoria
   AND eg.classe_produto      = mcpc.classe
   AND eg.sub_classe_produto  = mcpc.subclasse
WHERE 
    eg.data_hora_entregue >= DATE '2025-01-01'
    AND eg.data_hora_entregue <  DATE '2026-01-01'
    AND (
        eg.categoria_produto ILIKE '%CHAPAR%' 
        OR eg.categoria_produto ILIKE '%VIDRO%' 
        OR eg.categoria_produto ILIKE '%BOX P%' 
        OR eg.categoria_produto ILIKE '%TEMPERADO%'
    )
GROUP BY 
    eg.tipo_unidade,
    eg.unidade,
    eg.tipo_produto,
    date_trunc('month', eg.data_hora_entregue),
    eg.categoria_produto,
    eg.classe_produto,
    eg.sub_classe_produto,
    eg.cod_produto,
    eg.nome_produto,
    mcpc.hva
ORDER BY 
    eg.unidade,
    mes_ref,
    eg.nome_produto;
    