WITH pedidos_junho AS (
    SELECT DISTINCT
        p.unidade,
        p.cod_cliente,
        p.nome_cliente,
        p.cod_pedido,
        REPLACE(p.valor_final_pedido, ',', '.') AS valor_final_pedido
    FROM pedidos p
    WHERE p.data_pedido::date BETWEEN '2025-06-01' AND '2025-06-30'
      AND p.unidade = 'GM Maceio'
      AND (
          p.categoria_produto = 'TEMPERADO' 
          OR p.categoria_produto = 'TEMPERADO ESPECIAL'
      )
),
clientes_julho AS (
    SELECT DISTINCT
        p.cod_cliente
    FROM pedidos p
    WHERE p.data_pedido::date BETWEEN '2025-07-01' AND '2025-07-31'
      AND p.unidade = 'GM Maceio'
      AND (
          p.categoria_produto = 'TEMPERADO' 
          OR p.categoria_produto = 'TEMPERADO ESPECIAL'
      )
)
SELECT
    pj.cod_cliente,
    pj.nome_cliente,
    SUM(CAST(pj.valor_final_pedido AS numeric)) AS valor_total_junho
FROM pedidos_junho pj
LEFT JOIN clientes_julho cj ON cj.cod_cliente = pj.cod_cliente
WHERE cj.cod_cliente IS NULL -- só quem não comprou em julho
GROUP BY pj.cod_cliente, pj.nome_cliente
ORDER BY valor_total_junho DESC;





WITH pedidos_junho AS (
    SELECT
        DISTINCT p.cod_pedido,
        p.cod_cliente,
        p.nome_cliente,
        p.unidade,
        CAST(REPLACE(p.valor_final_pedido, ',', '.') AS numeric) AS valor_junho
    FROM pedidos p
    WHERE p.data_pedido::date BETWEEN '2025-06-01' AND '2025-06-30'
      AND p.unidade = 'GM Maceio'
),
pedidos_julho AS (
    SELECT
        DISTINCT p.cod_pedido,
        p.cod_cliente,
        p.nome_cliente,
        p.unidade,
        CAST(REPLACE(p.valor_final_pedido, ',', '.') AS numeric) AS valor_julho
    FROM pedidos p
    WHERE p.data_pedido::date BETWEEN '2025-07-01' AND '2025-07-31'
      AND p.unidade = 'GM Maceio'
),
soma_junho AS (
    SELECT cod_cliente, nome_cliente, unidade, SUM(valor_junho) AS valor_vendido_junho
    FROM pedidos_junho
    GROUP BY cod_cliente, nome_cliente, unidade
),
soma_julho AS (
    SELECT cod_cliente, nome_cliente, unidade, SUM(valor_julho) AS valor_vendido_julho
    FROM pedidos_julho
    GROUP BY cod_cliente, nome_cliente, unidade
)
SELECT
    COALESCE(jun.cod_cliente, jul.cod_cliente) AS cod_cliente,
    COALESCE(jun.nome_cliente, jul.nome_cliente) AS nome_cliente,
    COALESCE(jun.unidade, jul.unidade) AS unidade,
    COALESCE(jun.valor_vendido_junho, 0) AS valor_vendido_junho,
    COALESCE(jul.valor_vendido_julho, 0) AS valor_vendido_julho
FROM soma_junho jun
FULL OUTER JOIN soma_julho jul
  ON jun.cod_cliente = jul.cod_cliente AND jun.unidade = jul.unidade
ORDER BY valor_vendido_junho DESC;r