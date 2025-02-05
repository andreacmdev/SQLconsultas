-- mapeamento contas internas mês a mês
SELECT
     %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,  
    meses.yearmonth AS mes_referencia,
    contas.NU_CON AS nu_documento,
    contas.ds_con AS nome_cliente,
    (
        SELECT m.SLD_ATUAL
        FROM mgcon01011 m
        WHERE m.NU_CON = contas.NU_CON
          AND DATE_FORMAT(m.DT_REF, '%Y-%m') <= meses.yearmonth
        ORDER BY m.DT_REF DESC
        LIMIT 1
    ) AS valor_titulo,
    (
        SELECT MAX(m.DT_REF)
        FROM mgcon01011 m
        WHERE m.NU_CON = contas.NU_CON
          AND DATE_FORMAT(m.DT_REF, '%Y-%m') <= meses.yearmonth
    ) AS last_updated
FROM (
    SELECT DATE_FORMAT(DATE_ADD('2024-01-01', INTERVAL seq MONTH), '%Y-%m') AS yearmonth
    FROM (
        SELECT 0 AS seq UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 
        UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 
        UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
    ) seqs
) meses
CROSS JOIN (
    SELECT DISTINCT NU_CON, ds_con 
    FROM mgcon01010
) contas
ORDER BY contas.NU_CON, meses.yearmonth;