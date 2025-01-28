SELECT
    mf.tipo_unidade,
    mf.unidade,
    mf.data_pagamento,
    mf.vlr_pago,
    mf.valor_titulo,
    mf.fornecedor_cliente,
    mf.classificacao,
    mf.descricao,
    mf.chave_detalhamento,
    mf.forma_pagamento,
    mf.nome_conta,
    mf.tipo_de_lancamento,
    mf.plano_conta,
    mf.colaborador,
    CASE 
        WHEN tpc_info.valor_titulo_pendente IS NOT NULL THEN 'Fornecedor com título pendente'
        ELSE 'Sem títulos pendentes'
    END AS status_titulo_pendente,
    tpc_info.valor_titulo_pendente,
    tpc_info.qtd_titulos_pendentes,
    tpc_info.data_vencimento_agrupada  -- Aqui trazemos as datas agrupadas
FROM movimentacoes_financeiras mf
LEFT JOIN (
    SELECT 
        unidade,
        fornecedor,
        SUM(COALESCE(REPLACE(valor_titulo, ',', '.')::numeric, 0)) AS valor_titulo_pendente,
        COUNT(*) AS qtd_titulos_pendentes,
        array_agg(DISTINCT data_vencimento ORDER BY data_vencimento) AS data_vencimento_agrupada  -- Agrupando as datas
    FROM titulos_pendentes_compras
    GROUP BY unidade, fornecedor
) tpc_info 
    ON mf.unidade = tpc_info.unidade 
   AND mf.fornecedor_cliente = tpc_info.fornecedor
WHERE 
    mf.data_pagamento::date = CURRENT_DATE - 1
    AND mf.tipo_de_lancamento = 'Saida'
    AND mf.descricao ILIKE '%ADIANT%'
    AND mf.fornecedor_cliente IS NOT NULL
ORDER BY 
    mf.unidade, mf.fornecedor_cliente;