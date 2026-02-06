SELECT
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade, 
    YEAR(nfe.DT_EMISSAO)  AS ano,
    MONTH(nfe.DT_EMISSAO) AS mes,
    SUM(nfe.VLR_TOTAL_PRO)  AS valor_total_produto,
    SUM(nfe.VLR_TOTAL_NOTA) AS valor_total_nf
FROM mgnfe01010 nfe
WHERE nfe.TP_NOTA = '2'
  AND nfe.ID_STATUS = '2'
  AND nfe.DT_EMISSAO >= '2023-01-01'
GROUP BY
    YEAR(nfe.DT_EMISSAO),
    MONTH(nfe.DT_EMISSAO)
ORDER BY
    ano,
    mes;
