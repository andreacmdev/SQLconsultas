-- Saídas não operacionais
SELECT 
    mf.tipo_unidade,
    mf.unidade,
    mf.tipo_de_lancamento,
    TO_DATE(mf.data_pagamento, 'YYYY/MM/DD') AS data_pagamento,
    mf.plano_conta,
    TO_DATE(mf.data_vencimento, 'YYYY/MM/DD') AS data_vencimento,
    mf.nome_conta ,
    mf.classificacao,
    mf.descricao,
    CAST(REPLACE(mf.vlr_pago, ',', '.') AS NUMERIC) AS vlr_pago,
    cast(replace(mf.valor_titulo, ',' , '.') as numeric) as valor_titulo 
FROM  
    movimentacoes_financeiras mf 
WHERE 
    TO_DATE(mf.data_pagamento, 'YYYY/MM/DD') BETWEEN '2024-07-11' AND '2024-07-17'
    and tipo_unidade = 'Bodinho'
    and mf.tipo_de_lancamento = 'Saida'
ORDER BY 
    mf.unidade; 
