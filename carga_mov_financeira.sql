-- movimentacao_financeira
SELECT 
	mf.id ,
	mf.chave ,
	mf.cod_dlt ,
	mf.unidade ,
    CAST(REPLACE(mf.vlr_pago, ',', '.') AS NUMERIC) AS vlr_pago ,
	mf.descricao ,
	mf.documento ,
	mf.nome_conta ,
	mf.colaborador ,
	mf.plano_conta ,
	mf.centro_custo ,
	mf.tipo_unidade ,
	mf.classificacao ,
    TO_DATE(mf.data_pagamento, 'YYYY/MM/DD') AS data_pagamento,
	mf.forma_pagamento ,
	mf.nivel_plano_conta ,
	mf.fornecedor_cliente ,
	mf.nivel_centro_custo ,
	mf.tipo_de_lancamento 
FROM  
    movimentacoes_financeiras mf 
WHERE 
   TO_DATE(mf.data_pagamento, 'YYYY/MM/DD') BETWEEN '2024-06-01' AND '2024-06-30'
ORDER BY 
    mf.unidade;    