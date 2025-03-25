-- Produtos inativos/ativos n8n ------------------------------------------------
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
WHERE m.TABELA = 'mgpro01010'
AND m.DTH >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
AND (
    m.DS_LOG LIKE '%ID_ATIVO=de "N" para "S"%'
    OR m.DS_LOG LIKE '%ID_ATIVO=de "S" para "N"%'
);



-------------------------------------- code -------------------------------------------------


return items.map(item => {
    const log = item.json.DS_LOG;
    let nuPro = null;

    if (log && typeof log === 'string') {
        const match = log.match(/NU_PRO=(\d+)/);
        if (match) {
            nuPro = parseInt(match[1], 10);
        }
    }

    return {
        json: {
            ...item.json,
            NU_PRO: nuPro
        }
    };
});



----------------------------------- mysql ------------------------------------------------

SELECT 
'{{ $json["tipo_unidade"] }}' as tipo_unidade,
'{{ $json["unidade"] }}' as unidade, 
    produto.NU_PRO,
    produto.DS_PRO,
    produto.NU_ESTOQAT
FROM mgpro01010 produto
WHERE produto.NU_PRO IN ({{$json["NU_PRO"]}}) AND produto.NU_ESTOQAT > 0;

