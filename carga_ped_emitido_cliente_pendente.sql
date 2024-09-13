WITH RecentOrders AS (
    SELECT 
        cod_cliente, 
        nome_cliente, 
        unidade, 
        MAX(data_hora_pedido) AS data_hora_pedido  -- Pega o timestamp mais recente para o cliente
    FROM pedidos
    WHERE data_hora_pedido >= NOW() - INTERVAL '30 minutes'  -- Pedidos dos últimos 30 minutos
    GROUP BY cod_cliente, nome_cliente, unidade
),
Pendencias AS (
    SELECT 
        p.cod_cliente, 
        p.unidade,
        COUNT(*) AS qtd_pendencias  -- Contagem de pedidos com pendência
    FROM pedidos p
    WHERE p.status_pedido = 'Aberto' 
      AND p.data_hora_pedido < NOW() - INTERVAL '30 days'  -- Pedidos abertos há mais de 30 dias
    GROUP BY p.cod_cliente, p.unidade
),
PagamentosPendentes AS (
    SELECT 
        p.cod_cliente, 
        p.unidade
    FROM pedidos p
    WHERE p.status_pedido = 'Aberto'
      AND p.pedido_pago != 'S'  -- Verifica se o pedido não está pago
      AND p.data_hora_pedido < NOW() - INTERVAL '30 days'  -- Pedidos abertos há mais de 30 dias
    GROUP BY p.cod_cliente, p.unidade
)
SELECT 
    ro.cod_cliente, 
    ro.nome_cliente, 
    ro.unidade, 
    ro.data_hora_pedido,
    CASE 
        WHEN pp.cod_cliente IS NOT NULL THEN 'TEM PENDÊNCIA E NÃO ESTÁ PAGO'
        WHEN pe.cod_cliente IS NOT NULL THEN 'TEM PENDÊNCIA, MAS ESTÁ PAGO'
        ELSE 'NÃO TEM PENDÊNCIA'
    END AS pendencia_status
FROM RecentOrders ro
LEFT JOIN Pendencias pe ON ro.cod_cliente = pe.cod_cliente AND ro.unidade = pe.unidade
LEFT JOIN PagamentosPendentes pp ON ro.cod_cliente = pp.cod_cliente AND ro.unidade = pp.unidade
ORDER BY ro.data_hora_pedido DESC;
