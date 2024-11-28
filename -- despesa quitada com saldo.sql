-- despesa quitada com saldo sem ser pedido de compra
SELECT 
    mf.tipo_unidade,
    mf.unidade,
    mf.chave ,
    df.chave ,
    mf.chave_detalhamento ,
    mf.classificacao,
    mf.centro_custo,
    mf.plano_conta,
    mf.descricao,
	mf.fornecedor_cliente ,
    df.forma_pagamento ,
    mf.vlr_pago,
    DATE(mf.data_pagamento ::date) as data_pagamento 
FROM 
    movimentacoes_financeiras mf 
left join 
	detalhamento_financeiro df on mf.unidade = df.unidade and mf.chave = df.chave 
WHERE 
    mf.tipo_de_lancamento = 'Saida'
    and df.forma_pagamento = 'Saldo'
    AND mf.data_pagamento::date = current_date - INTERVAL '1 day'
    and mf.classificacao not ilike '%COMPRA%';