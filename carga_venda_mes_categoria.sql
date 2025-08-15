-- venda por mes / categoria
WITH params AS (
  SELECT DATE '2025-04-01' AS inicio, DATE '2025-09-01' AS fim
),
base AS (
  SELECT
    p.unidade,
    p.cod_cliente,
    p.nome_cliente,
    REPLACE(p.valor_unitario_total_com_desconto, ',', '.')::numeric AS valor,
    REPLACE(p.metragem_cobrada, ',', '.')::numeric                  AS metragem,
    date_trunc('month', p.data_pedido)::date                        AS mes
  FROM pedidos p
  JOIN params pa ON p.data_pedido >= pa.inicio AND p.data_pedido < pa.fim
  WHERE p.unidade ILIKE 'GM MACEIO'
    AND p.categoria_produto = 'CHAPARIA ESPELHO'
)
SELECT
  unidade,
  cod_cliente,
  nome_cliente,
  ROUND(COALESCE(SUM(valor)    FILTER (WHERE mes = DATE '2025-04-01'), 0), 2) AS valor_abril,
  ROUND(COALESCE(SUM(metragem) FILTER (WHERE mes = DATE '2025-04-01'), 0), 2) AS metragem_abril,
  ROUND(COALESCE(SUM(valor)    FILTER (WHERE mes = DATE '2025-05-01'), 0), 2) AS valor_maio,
  ROUND(COALESCE(SUM(metragem) FILTER (WHERE mes = DATE '2025-05-01'), 0), 2) AS metragem_maio,
  ROUND(COALESCE(SUM(valor)    FILTER (WHERE mes = DATE '2025-06-01'), 0), 2) AS valor_junho,
  ROUND(COALESCE(SUM(metragem) FILTER (WHERE mes = DATE '2025-06-01'), 0), 2) AS metragem_junho,
  ROUND(COALESCE(SUM(valor)    FILTER (WHERE mes = DATE '2025-07-01'), 0), 2) AS valor_julho,
  ROUND(COALESCE(SUM(metragem) FILTER (WHERE mes = DATE '2025-07-01'), 0), 2) AS metragem_julho,
  ROUND(COALESCE(SUM(valor)    FILTER (WHERE mes = DATE '2025-08-01'), 0), 2) AS valor_agosto,
  ROUND(COALESCE(SUM(metragem) FILTER (WHERE mes = DATE '2025-08-01'), 0), 2) AS metragem_agosto
FROM base
GROUP BY unidade, cod_cliente, nome_cliente
ORDER BY nome_cliente;