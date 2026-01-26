SELECT
    pc.unidade,
    pc.cod_fornecedor,
    pc.fornecedor,
    SUM(NULLIF(REPLACE(pc.valor_pago , ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-01-01') AS jan_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-02-01') AS fev_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-03-01') AS mar_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-04-01') AS abr_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-05-01') AS mai_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-06-01') AS jun_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-07-01') AS jul_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-08-01') AS ago_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-09-01') AS set_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-10-01') AS out_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-11-01') AS nov_2025,
    SUM(NULLIF(REPLACE(pc.valor_pago, ',', '.'), '')::numeric)
        FILTER (WHERE date_trunc('month', pc.data_pedido::timestamp) = DATE '2025-12-01') AS dez_2025
FROM pedidos_compras pc
WHERE
    pc.tipo_unidade = 'Tempera'
    AND pc.data_pedido::timestamp >= '2025-01-01'
    AND pc.data_pedido::timestamp <  '2026-01-01'
GROUP BY
    pc.unidade,
    pc.cod_fornecedor,
    pc.fornecedor
ORDER BY
    pc.unidade,
    pc.fornecedor;