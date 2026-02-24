WITH base AS (
  SELECT
    fornecedor,
    unidade AS unidade_destino,
    pedido,
    data_pedido::timestamp AS dt,
    -- normaliza moeda/texto (remove R$, espaços)
    REGEXP_REPLACE(valor_pago, '[^0-9\.,-]', '', 'g') AS vtxt
  FROM pedidos_compras
  WHERE data_pedido::timestamp >= DATE '2025-01-01'
    AND data_pedido::timestamp <  DATE '2026-01-01'
    and tipo_unidade = 'Tempera'
),
pedido_unico AS (
  SELECT
    fornecedor,
    unidade_destino,
    pedido,
    -- garante UM mês por pedido (pega a menor data do pedido)
    DATE_TRUNC('month', MIN(dt))::date AS mes,
    -- garante UM valor por pedido (pega o maior valor numérico após conversão)
    MAX(
      CASE
        -- caso BR: tem ponto e vírgula (1.234,56)
        WHEN vtxt LIKE '%,%' AND vtxt LIKE '%.%' THEN
          REPLACE(REPLACE(vtxt, '.', ''), ',', '.')::numeric
        -- caso só vírgula (1234,56) -> BR
        WHEN vtxt LIKE '%,%' AND vtxt NOT LIKE '%.%' THEN
          REPLACE(vtxt, ',', '.')::numeric
        -- caso só ponto (1234.56) -> US
        WHEN vtxt LIKE '%.%' AND vtxt NOT LIKE '%,%' THEN
          vtxt::numeric
        -- caso inteiro (123456)
        ELSE
          NULLIF(vtxt, '')::numeric
      END
    ) AS valor_pago
  FROM base
  GROUP BY fornecedor, unidade_destino, pedido
)
SELECT
  fornecedor,
  unidade_destino,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-01-01') AS jan_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-02-01') AS fev_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-03-01') AS mar_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-04-01') AS abr_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-05-01') AS mai_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-06-01') AS jun_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-07-01') AS jul_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-08-01') AS ago_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-09-01') AS set_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-10-01') AS out_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-11-01') AS nov_2025,
  SUM(valor_pago) FILTER (WHERE mes = DATE '2025-12-01') AS dez_2025
FROM pedido_unico
GROUP BY fornecedor, unidade_destino
ORDER BY unidade_destino, fornecedor;