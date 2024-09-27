WITH pedidos_pendentes AS (
    SELECT 
        p.cod_pedido,
        p.tipo_unidade,
        p.unidade AS unidade_pendente,
        p.cod_cliente,
        p.nome_cliente,
        p.data_pedido,
        pp.status_pagamento
    FROM pedidos p
    LEFT JOIN pagamentos_pedidos pp
        ON pp.cod_pedido = p.cod_pedido AND pp.unidade = p.unidade
    WHERE p.tipo_pedido = 'Engenharia'
      AND p.status_pedido = 'Aberto'
      AND p.data_pedido <= NOW() - INTERVAL '30 days'
),
pedidos_recentes AS (
    SELECT DISTINCT
        nome_cliente,
        unidade AS unidade_novo_pedido
    FROM pedidos
    WHERE TO_TIMESTAMP(last_updated, 'YYYY-MM-DD HH24:MI:SS') >= NOW() - INTERVAL '30 minutes'
)
SELECT DISTINCT ON (pp.cod_cliente)
    pp.cod_pedido,
    pp.tipo_unidade,
    pp.unidade_pendente,
    pr.unidade_novo_pedido, 
    pp.cod_cliente,
    pp.nome_cliente,
    pp.data_pedido,
    pp.status_pagamento,
    CASE
        WHEN pr.nome_cliente IS NOT NULL THEN 'Sim'
        ELSE 'Não'
    END AS emitiu_recentes,
    mc.ramo_atividade
FROM pedidos_pendentes pp
LEFT JOIN pedidos_recentes pr
    ON pp.nome_cliente = pr.nome_cliente
LEFT JOIN mapeamento_clientes mc
    ON pp.cod_cliente = mc.codcliente
    AND pp.unidade_pendente = mc.unidade
WHERE pp.status_pagamento = 'Pendente'
  AND CASE
        WHEN pr.nome_cliente IS NOT NULL THEN 'Sim'
        ELSE 'Não'
    END = 'Sim'
ORDER BY pp.cod_cliente, pp.data_pedido DESC;