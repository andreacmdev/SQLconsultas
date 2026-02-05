SELECT
    eg.tipo_unidade,
    eg.unidade,
    SUM(valor_entregue) FILTER (
        WHERE data_hora_entregue >= DATE '2025-06-01'
          AND data_hora_entregue <  DATE '2025-07-01'
    ) AS jun_2025,
    SUM(valor_entregue) FILTER (
        WHERE data_hora_entregue >= DATE '2025-07-01'
          AND data_hora_entregue <  DATE '2025-08-01'
    ) AS jul_2025,
    SUM(valor_entregue) FILTER (
        WHERE data_hora_entregue >= DATE '2025-08-01'
          AND data_hora_entregue <  DATE '2025-09-01'
    ) AS ago_2025,
    SUM(valor_entregue) FILTER (
        WHERE data_hora_entregue >= DATE '2025-09-01'
          AND data_hora_entregue <  DATE '2025-10-01'
    ) AS set_2025,
    SUM(valor_entregue) FILTER (
        WHERE data_hora_entregue >= DATE '2025-10-01'
          AND data_hora_entregue <  DATE '2025-11-01'
    ) AS out_2025,
    SUM(valor_entregue) FILTER (
        WHERE data_hora_entregue >= DATE '2025-11-01'
          AND data_hora_entregue <  DATE '2025-12-01'
    ) AS nov_2025,
    SUM(valor_entregue) FILTER (
        WHERE data_hora_entregue >= DATE '2025-12-01'
          AND data_hora_entregue <  DATE '2026-01-01'
    ) AS dez_2025
FROM entregas_geral eg
left join mapeamento_clientes mc on eg.cod_cliente = mc.codcliente and eg.unidade = mc.unidade
WHERE
    eg.data_hora_entregue >= DATE '2025-06-01'
    AND eg.data_hora_entregue <  DATE '2026-01-01'
    and mc.ramo_atividade != 'INTERCOMPANY'
GROUP BY
    eg.tipo_unidade,
    eg.unidade
ORDER BY
    eg.tipo_unidade,
    eg.unidade;