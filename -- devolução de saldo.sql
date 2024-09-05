-- devolução de saldo
SELECT 
	mf.id ,
	mf.chave ,
	mf.unidade ,
	mf.tipo_unidade ,
    CAST(REPLACE(mf.vlr_pago, ',', '.') AS NUMERIC) AS vlr_pago ,
	mf.descricao ,
	mf.nome_conta ,
	mf.classificacao ,
    TO_DATE(mf.data_pagamento, 'YYYY/MM/DD') AS data_pagamento
FROM  
    movimentacoes_financeiras mf 
WHERE 
   TO_DATE(mf.data_pagamento, 'YYYY/MM/DD') = CURRENT_DATE - 1
   and mf.classificacao like '%SALDO%' 
ORDER BY 
    mf.unidade;