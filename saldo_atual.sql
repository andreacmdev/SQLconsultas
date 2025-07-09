-- SALDO ATUAL CONTAS INTERNAS
SELECT 
	%(Tipo_Unidade)s AS Tipo_Unidade,
	%(Unidade)s AS Unidade,
    conta.NU_CON, 
    conta.DS_CON, 
    conta.ID_ATIVO, 
    saldo.SLD_ATUAL, 
    saldo.DT_LANCTO
FROM mgcon01010 conta
LEFT JOIN (
    SELECT 
        s1.NU_CON, 
        s1.SLD_ATUAL, 
        s1.DT_LANCTO
    FROM mgcon01011 s1
    INNER JOIN (
        SELECT 
            NU_CON, 
            MAX(DT_LANCTO) AS DT_LANCTO
        FROM mgcon01011
        GROUP BY NU_CON
    ) ult ON s1.NU_CON = ult.NU_CON 
         AND s1.DT_LANCTO = ult.DT_LANCTO
) saldo ON conta.NU_CON = saldo.NU_CON
WHERE conta.ID_ATIVO = 'S';