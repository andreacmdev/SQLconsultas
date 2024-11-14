-- auditoria despesa de compras
   SELECT 
    mf.tipo_unidade,
    mf.unidade,
    mf.tipo_de_lancamento,
    mf.chave,
    mf.descricao,
    SUM(CAST(REPLACE(df.valor_pago, ',', '.') AS NUMERIC)) AS valor_total_pago,
    STRING_AGG(df.forma_pagamento, ', ') AS formas_pagamento
FROM 
    movimentacoes_financeiras mf
LEFT JOIN 
    detalhamento_financeiro df 
ON 
    mf.chave = df.chave 
    AND mf.unidade = df.unidade
WHERE 
    mf.classificacao IN ('4. Compra de Mercadoria', 'Compra de Mercadoria')
    AND mf.plano_conta NOT IN ('Frete de Entrega', 'Frete de Mercadoria', 'Fretes')
    AND TO_DATE(mf.data_pagamento , 'YYYY-MM-DD') = current_date - interval '30 day'
    and mf.tipo_de_lancamento = 'Saida'
    AND df.forma_pagamento != 'Saldo'
GROUP BY 
    mf.tipo_unidade,
    mf.unidade,
    mf.tipo_de_lancamento,
    mf.chave,
    mf.descricao