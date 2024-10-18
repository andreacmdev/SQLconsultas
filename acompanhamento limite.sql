-- acompanhamento de limite
SELECT
    saldo.NU_CLI,
    saldo.DS_CLI,
    saldo.APEL_FANT,
    saldo.SLD_CLI,
    saldo.LMT_CRED,
    saldo.DT_INS,
    saldo.ID_BLOQ,
    limite.LIM_CART,
    limite.LIM_CHQ,
    limite.LIM_CHQ_TER,
    limite.LIM_BOL,
    pedidos.NU_PVE ,
    pedidos.DT_PVE,
    pedidos.ID_STATUS,
    formas.TP_PAGTO,
    CASE 
        WHEN formas.TP_PAGTO = 1 AND formas.NU_CON IS NULL THEN 'Dinheiro'
        WHEN formas.TP_PAGTO = 1 AND formas.NU_CON IS NOT NULL THEN 'Conta Interna'
        WHEN formas.TP_PAGTO = 2 THEN 'Cheque'
        WHEN formas.TP_PAGTO = 3 THEN 'Cartao'
        WHEN formas.TP_PAGTO = 4 THEN 'Saldo'
        WHEN formas.TP_PAGTO = 5 THEN 'Outros'
        WHEN formas.TP_PAGTO = 6 THEN 'Boleto'
        WHEN formas.TP_PAGTO = 7 THEN 'Deposito'
        WHEN formas.TP_PAGTO = 8 THEN 'Duplicata'
        WHEN formas.TP_PAGTO = 9 THEN 'Saldo de Outro Cliente'
        ELSE 'Nao Determinado'
    END AS forma_pagamento,
    SUM(pedidos.VLR_TOT_PVE) AS total_valor,
    pedidos.VLR_TOT_PVE AS total_valor,
    limite.LIM_DUP
FROM 
    mgcli01010 saldo
LEFT JOIN 
    mgcli01016 limite ON saldo.NU_CLI = limite.NU_CLI
LEFT JOIN 
    mgcta01014 titulos ON saldo.NU_CLI = titulos.NU_CLI
LEFT JOIN 
    mgcta01018 formas ON titulos.NU_CLT = formas.NU_CLT
LEFT JOIN 
    mgpve01010 pedidos ON saldo.NU_CLI = pedidos.NU_CLI

   -- GROUP BY 
    saldo.NU_CLI,
    saldo.DS_CLI,
    saldo.APEL_FANT,
    saldo.SLD_CLI,
    saldo.LMT_CRED,
    saldo.DT_INS,
    saldo.ID_BLOQ,
    limite.LIM_CART,
    limite.LIM_CHQ,
    limite.LIM_CHQ_TER,
    limite.LIM_BOL,
    formas.TP_PAGTO,
    formas.NU_CON,
    limite.LIM_DUP,
    pedidos.NU_PVE 
ORDER BY 
    saldo.NU_CLI