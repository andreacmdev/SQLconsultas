-- pedidos emitidos para clientes em aberto + valorpendente
WITH RecentOrders AS (
    SELECT 
        cod_pedido,
        cod_cliente, 
        nome_cliente, 
        unidade, 
        MAX(data_hora_pedido) AS data_hora_pedido
    FROM pedidos
    WHERE data_hora_pedido >= NOW() - INTERVAL '30 minutes'
    GROUP BY cod_pedido, cod_cliente, nome_cliente, unidade
),
PagamentosPendentes AS (
    SELECT 
        spp.cod_pedido,
        spp.unidade,
        SUM(spp.totalpendente) AS valor_pendente
    FROM status_pagamento_pedidos spp
    WHERE spp.totalpendente != 0
      AND EXISTS (
        SELECT 1
        FROM pedidos p
        WHERE p.cod_pedido = spp.cod_pedido
          AND p.data_hora_pedido < NOW() - INTERVAL '30 days'
      )
    GROUP BY spp.cod_pedido, spp.unidade
),
FilteredPendencias AS (
    SELECT 
        ro.cod_cliente, 
        ro.nome_cliente, 
        ro.unidade, 
        ro.data_hora_pedido,
        CASE 
            WHEN pp.cod_pedido IS NOT NULL THEN 'TEM PENDÊNCIA E NÃO ESTÁ PAGO'
            ELSE 'NÃO TEM PENDÊNCIA'
        END AS pendencia_status,
        COALESCE(SUM(pp.valor_pendente), 0) AS valor_pendente
    FROM RecentOrders ro
    LEFT JOIN PagamentosPendentes pp ON ro.cod_pedido = pp.cod_pedido AND ro.unidade = pp.unidade
    GROUP BY ro.cod_cliente, ro.nome_cliente, ro.unidade, ro.data_hora_pedido, pendencia_status
)
-- garantir apenas uma linha por cliente
SELECT
    cod_cliente,
    nome_cliente,
    unidade,
    MAX(data_hora_pedido) AS data_hora_pedido,
    pendencia_status,
    SUM(valor_pendente) AS valor_pendente
FROM FilteredPendencias
GROUP BY cod_cliente, nome_cliente, unidade, pendencia_status
ORDER BY unidade DESC;