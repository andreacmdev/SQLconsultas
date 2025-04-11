-- auditoria contas Internas

SELECT
    m.NU_LOG,
    m.NU_USU,
    usuario.DS_LOGIN AS login,
    usuario.NOM_USU AS nome_usuario,
    m.DTH AS data_operacao,
    m.tipo,
    m.TABELA,
    m.DS_LOG,
    conta.NU_CON,
    conta.DS_CON,
    saldo.SLD_ATUAL
FROM mglog01011 m
LEFT JOIN mgusu01010 usuario ON m.NU_USU = usuario.NU_USU
LEFT JOIN mgcon01010 conta ON conta.NU_CON = 
    CAST(SUBSTRING(m.DS_LOG, 
                   LOCATE('NU_CON=', m.DS_LOG) + 7, 
                   LOCATE(';', m.DS_LOG) - (LOCATE('NU_CON=', m.DS_LOG) + 7)) AS UNSIGNED)
LEFT JOIN (
    SELECT NU_CON, MAX(DT_LANCTO) AS DT_LANCTO, SLD_ATUAL
    FROM mgcon01011
    GROUP BY NU_CON
) saldo ON conta.NU_CON = saldo.NU_CON AND saldo.DT_LANCTO = 
    (SELECT MAX(DT_LANCTO) 
     FROM mgcon01011 
     WHERE NU_CON = saldo.NU_CON)
WHERE m.TABELA = 'mgcon01010'
AND m.TIPO = '3'
AND m.DTH >= DATE_SUB(NOW(), INTERVAL 1 HOUR);


------------------------------------------ N8N----------------------------------------------

SELECT 
    '{{ $json["tipo_unidade"] }}' as tipo_unidade,
    '{{ $json["unidade"] }}' as unidade,
    m.NU_LOG,
    m.NU_USU,
    usuario.DS_LOGIN AS login,
    usuario.NOM_USU AS nome_usuario,
    m.DTH AS data_operacao,
    m.tipo,
    m.TABELA,
    m.DS_LOG
FROM mglog01011 m
LEFT JOIN mgusu01010 usuario ON m.NU_USU = usuario.NU_USU
WHERE m.TABELA = 'mgcon01010'
AND m.TIPO = '3'
AND m.DTH >= DATE_SUB(NOW(), INTERVAL 1 HOUR);


--------------------------- code --------------------------------------------
return items.map(item => {
    const log = item.json.DS_LOG;
    let nuCon = null;

    if (log && typeof log === 'string') {
        const match = log.match(/NU_CON=(\d+)/);
        if (match) {
            nuCon = parseInt(match[1], 10);
        }
    }

    return {
        json: {
            ...item.json,
            NU_CON: nuCon
        }
    };
});

-------------------------------------- MySQL ------------------------------------


SELECT 
'{{ $json["tipo_unidade"] }}' as tipo_unidade,
'{{ $json["unidade"] }}' as unidade,
    conta.NU_CON,
    conta.DS_CON,
    saldo.SLD_ATUAL
FROM mgcon01010 conta
LEFT JOIN mgcon01011 saldo 
    ON conta.NU_CON = saldo.NU_CON
    AND saldo.DT_LANCTO = (
        SELECT MAX(s2.DT_LANCTO) 
        FROM mgcon01011 s2 
        WHERE s2.NU_CON = saldo.NU_CON
    )
WHERE conta.NU_CON IN ({{$json["NU_CON"]}});
