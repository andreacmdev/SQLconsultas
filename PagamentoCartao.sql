select 
	%(Tipo_Unidade)s as Tipo_Unidade,
	%(Unidade)s as Unidade,
    dsf.DT_DSF, 
    card.*, 
    conta.DS_CON AS Conta, 
    cliente.DS_CLI,
    clt.nu_cta,
    ROUND(Valor / QtdParcelas, 2) AS ValorParcela,
    CASE   
        WHEN TP_ESPECIE = 4 THEN 'BOLETO'
        WHEN TP_ESPECIE = 2 THEN 'DINHEIRO'
        WHEN TP_ESPECIE = 3 THEN 'CARTÃO'
        WHEN TP_ESPECIE = 0 THEN 'CHEQUE'
        WHEN TP_ESPECIE = 1 THEN 'DUPLICATA'
    END AS tipodsf,
    identificacao
FROM (
    SELECT 
        NU_DLT,
        recebimentos.NU_DSF,
        recebimentos.NU_CLT_ORIGEM,
        cartoes.DS_CAR AS Cartao,
        SUBSTRING_INDEX(ident_cartao, "-", 1) AS Identificacao,
        SUM(VLR_CARTAO) AS Valor,
        COUNT(DISTINCT IDENT_CARTAO) AS QtdParcelas
    FROM
        mgcta01019 recebimentos
    LEFT JOIN
        mgcar01010 cartoes ON recebimentos.NU_CAR = cartoes.NU_CAR 
    GROUP BY
        NU_DLT,
        recebimentos.NU_DSF,
        recebimentos.NU_CLT_ORIGEM,
        cartoes.DS_CAR,
        SUBSTRING_INDEX(ident_cartao, "-", 1)
) card
LEFT JOIN mgdsf01010 dsf ON dsf.NU_DSF = card.NU_DSF
LEFT JOIN mgcta01014 clt ON card.NU_CLT_ORIGEM = clt.NU_CLT
LEFT JOIN mgcli01010 cliente ON clt.NU_CLI = cliente.NU_CLI
LEFT JOIN mgcon01010 conta ON conta.NU_CON = dsf.NU_CON
LEFT JOIN mgban01010 banco ON banco.NU_BAN = dsf.NU_BAN
WHERE
    QtdParcelas >= 6
    AND DATE(dsf.DT_DSF) BETWEEN '2024-11-18' and '2024-11-25'
ORDER BY
    dsf.DT_DSF DESC;