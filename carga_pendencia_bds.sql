-- Saldos e mercadoria BDS
WITH pedidos_unicos AS (
    SELECT 
        tipo_unidade,
        unidade,
        cod_cliente,
        nome_cliente,
        cod_pedido,
        tipo_pedido
    FROM 
        pedidos
    WHERE 
        unidade = 'VITORIA DE SANTO ANTAO'
        AND nome_cliente IN (
            'PONTO DO VIDRO',
            'GRAVATA DISTRIBUIDORA DE VIDROS',
            'ARTHUR F SILVA DE OLIVEIRA VID',
            'IGARASSU DISTRIBUIDORA DE VIDROS',
            'PALMARES DISTRIBUIDORA DE VIDROS',
            'ARTUR F SILVA DE OLIVEIRA VIDROS',
            'SANTA CRUZ DISTRIBUIDORA DE VI',
            'GOIANA VIDROS',
            'PATOS VIDROS DISTRIBUIDORA',
            'CABO DIST. DE VIDROS'
        )
    GROUP BY 
        tipo_unidade, 
        unidade, 
        cod_cliente, 
        nome_cliente, 
        cod_pedido, 
        tipo_pedido
),
pendencias AS (
    SELECT 
        p.tipo_unidade,
        p.unidade,
        p.cod_cliente,
        CASE 
            WHEN p.nome_cliente = 'ARTHUR F SILVA DE OLIVEIRA VID' THEN 'ARCOVERDE'
            WHEN p.nome_cliente = 'ARTUR F SILVA DE OLIVEIRA VIDROS' THEN 'BELO JARDIM DISTRIBUIDORA'
            ELSE p.nome_cliente
        END AS nome_cliente,
        SUM(CASE WHEN p.tipo_pedido = 'Engenharia' THEN spp.totalpendente ELSE 0 END) AS pendencia_temperado,
        SUM(CASE WHEN p.tipo_pedido = 'Serie' THEN spp.totalpendente ELSE 0 END) AS pendencia_box,
        SUM(spp.totalpendente) AS pendencia_total
    FROM 
        pedidos_unicos p
    LEFT JOIN 
        status_pagamento_pedidos spp 
        ON p.cod_pedido = spp.cod_pedido AND p.unidade = spp.unidade
    WHERE 
        spp.totalpendente != 0
    GROUP BY 
        p.tipo_unidade,
        p.unidade,
        p.cod_cliente,
        p.nome_cliente
),
painel_financeiro_agrupado AS (
    SELECT 
        pf.unidade,
        CASE 
            WHEN pf.nome_cliente = 'Saldo Têmpera' THEN 'Saldo Têmpera'
            ELSE 'BTG+YOUPAY' 
        END AS conta_interna,
        SUM(CAST(REPLACE(pf.valor_titulo, ',', '.') AS NUMERIC)) AS total_valor_titulo, 
        CASE 
            WHEN pf.unidade = 'GRAVATA' THEN 'GRAVATA DISTRIBUIDORA DE VIDROS'
            WHEN pf.unidade = 'BELO JARDIM' THEN 'BELO JARDIM DISTRIBUIDORA'
            WHEN pf.unidade = 'ARCOVERDE' THEN 'ARCOVERDE'
            WHEN pf.unidade = 'CABO VIDROS' THEN 'CABO DIST. DE VIDROS'
            WHEN pf.unidade = 'PONTO VIDRO' THEN 'PONTO DO VIDRO'
            WHEN pf.unidade = 'IGARASSU' THEN 'IGARASSU DISTRIBUIDORA DE VIDROS'
            WHEN pf.unidade = 'GOIANA' THEN 'GOIANA VIDROS'
            WHEN pf.unidade = 'SANTA CRUZ' THEN 'SANTA CRUZ DISTRIBUIDORA DE VI'
        END AS nome_cliente_correspondente 
    FROM 
        painel_financeiro pf
    WHERE 
        pf.tipo_documento = 'Conta Interna'
    GROUP BY 
        pf.unidade,
        conta_interna
)
SELECT 
    p.tipo_unidade,
    p.unidade,
    p.cod_cliente,
    p.nome_cliente AS bodinho,
    p.pendencia_box,
    p.pendencia_temperado,
    p.pendencia_total,
    SUM(CASE WHEN pf.conta_interna = 'Saldo Têmpera' THEN pf.total_valor_titulo ELSE 0 END) AS saldo_tempera, 
    SUM(CASE WHEN pf.conta_interna = 'BTG+YOUPAY' THEN pf.total_valor_titulo ELSE 0 END) AS btg_youpay 
FROM 
    pendencias p
LEFT JOIN 
    painel_financeiro_agrupado pf 
    ON p.nome_cliente = pf.nome_cliente_correspondente
GROUP BY
    p.tipo_unidade,
    p.unidade,
    p.cod_cliente,
    p.nome_cliente,
    p.pendencia_box,
    p.pendencia_temperado,
    p.pendencia_total
ORDER BY 
    p.unidade, 
    p.nome_cliente;