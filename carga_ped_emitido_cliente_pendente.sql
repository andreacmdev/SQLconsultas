--pedido emitido para cliente pendente > 15 dias
WITH RecentOrders AS (
    SELECT 
        cod_cliente, 
        nome_cliente, 
        unidade, 
        MAX(data_hora_pedido) AS data_hora_pedido  -- Pega o timestamp mais recente para o cliente
    FROM pedidos
    WHERE data_hora_pedido >= NOW() - INTERVAL '30 minutes'  -- Pedidos dos últimos 30 minutos
    GROUP BY cod_cliente, nome_cliente, unidade
)
SELECT 
    ro.cod_cliente, 
    ro.nome_cliente, 
    ro.unidade, 
    ro.data_hora_pedido,
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM pedidos p2
            WHERE p2.cod_cliente = ro.cod_cliente
              AND p2.unidade = ro.unidade
              AND p2.status_pedido = 'Aberto'
              AND p2.data_hora_pedido < NOW() - INTERVAL '15 days'
        )
        THEN 'TEM PENDÊNCIA'
        ELSE 'NÃO TEM PENDÊNCIA'
    END AS pendencia_status
FROM RecentOrders ro
ORDER BY ro.data_hora_pedido DESC;