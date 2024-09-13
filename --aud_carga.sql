-- auditoria de carga
SELECT
    tipo_unidade,
    unidade, 
    tipo_entrega,
    tipo_veiculo,
    placa_veiculo,
    round(sum(valor_entregue + coalesce(acrescimo, 0)), 2),
    count(distinct(cod_romaneio)) AS total_romaneio,
    rota,
    data_hora_entregue,
    nome_cliente,
    cod_romaneio,
    carga
FROM
    entregas_geral eg
WHERE
    data_hora_entregue::Date = current_date - 1 
    AND carga IS NULL
    AND tipo_entrega = 'ENTREGA'
GROUP BY
    tipo_unidade, unidade, tipo_entrega, tipo_veiculo, placa_veiculo, rota, nome_cliente, cod_romaneio, data_hora_entregue, carga
UNION ALL
SELECT
    tipo_unidade,
    unidade, 
    tipo_entrega,
    tipo_veiculo,
    placa_veiculo,
    round(sum(valor_entregue + coalesce(acrescimo, 0)), 2),
    count(distinct(cod_romaneio)) AS total_romaneio,
    rota,
    data_hora_entregue,
    nome_cliente,
    cod_romaneio,
    carga
FROM
    entregas_geral eg
WHERE
    data_hora_entregue::Date = current_date - 1 
    AND carga IS NOT NULL
    AND tipo_entrega = 'ENTREGA'
GROUP BY
    tipo_unidade, unidade, tipo_entrega, tipo_veiculo, placa_veiculo, rota, nome_cliente, cod_romaneio, data_hora_entregue, carga