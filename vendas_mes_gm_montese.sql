SELECT
    tipo_unidade,
    unidade,
    cod_cliente,
    nome_cliente,
    cod_pedido,
    data_hora_pedido::date AS data_pedido,
    categoria_produto,
    classe_produto,
    sub_classe_produto,
    nome_produto,
    qtd_produto ,
    valor_unitario_total_com_desconto::numeric as valor_final_com_desconto ,
    vendedor,
    p.cond_pagamento
FROM pedidos p
WHERE unidade = 'GM MONTESE'
  AND p.data_hora_pedido >= date_trunc('month', CURRENT_DATE)
  AND p.data_hora_pedido <  date_trunc('month', CURRENT_DATE) + INTERVAL '1 month';
