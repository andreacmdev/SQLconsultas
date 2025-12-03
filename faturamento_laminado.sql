SELECT
	pedidos.cod_pedido
    , pedidos.cod_cliente
    , pedidos.nome_cliente
    , pedidos.cond_pagamento
    , pedidos.data_pedido
    , pedidos.status_pedido
    , REPLACE(pedidos.valor_total_pedido, ',', '.')::DOUBLE PRECISION AS valor_total_pedido
    , REPLACE(pedidos.valor_desconto, ',', '.')::DOUBLE PRECISION AS valor_desconto
    , (REPLACE(pedidos.percentual_desconto, ',', '.')::DOUBLE PRECISION / 100) AS percentual_desconto
    , REPLACE(pedidos.valor_acrescimo, ',', '.')::DOUBLE PRECISION AS valor_acrescimo
    , (REPLACE(pedidos.percentual_acrescimo, ',', '.')::DOUBLE PRECISION / 100) AS percentual_acrescimo
    , REPLACE(pedidos.valor_final_pedido, ',', '.')::DOUBLE PRECISION AS valor_final_pedido
    , pedidos.tipo_pedido
    , pedidos.previsao_entrega
    , pedidos.rota_entrega
    , pedidos.coes
    , pedidos.data_hora_pedido
    , pedidos.pedido_pronto
    , pedidos.cod_produto
    , pedidos.nome_produto
    , pedidos.categoria_produto
    , pedidos.classe_produto
    , pedidos.sub_classe_produto
    , REPLACE(pedidos.qtd_produto, ',', '.')::DOUBLE PRECISION AS qtd_produto
    , REPLACE(pedidos.valor_unitario_produto, ',', '.')::DOUBLE PRECISION AS valor_unitario_produto
    , pedidos.medida_altura::DOUBLE PRECISION AS medida_altura
    , pedidos.medida_largura::DOUBLE PRECISION AS medida_largura
    , pedidos.metragem_real::DOUBLE PRECISION AS metragem_real
    , pedidos.metragem_cobrada::DOUBLE PRECISION AS metragem_cobrada
    , REPLACE(pedidos.valor_unitario_total, ',', '.')::DOUBLE PRECISION AS valor_unitario_total
    , REPLACE(pedidos.valor_unitario_com_desconto, ',', '.')::DOUBLE PRECISION AS valor_unitario_com_desconto
    , REPLACE(pedidos.valor_unitario_total_com_desconto, ',', '.')::DOUBLE PRECISION AS valor_unitario_total_com_desconto
    , REPLACE(pedidos.custo_unitario_produto, ',', '.')::DOUBLE PRECISION AS custo_unitario_produto
    , REPLACE(pedidos.custo_unitario_total_produto, ',', '.')::DOUBLE PRECISION AS custo_unitario_total_produto
    , pedidos.margem_bruta_produto::DOUBLE PRECISION AS margem_bruta_produto
    , pedidos.tipo_produto
    , tipocoes.gerafaturamento AS gera_faturamento
    , tipocoes.tipopedido as coes_integrado
    , entregas.cod_romaneio
    , entregas.carga
    , entregas.tipo_entrega
    , entregas.tipo_veiculo
    , entregas.placa_veiculo
    , entregas.qtd_entregue::DOUBLE PRECISION AS qtd_entregue
    , entregas.metragem_entregue::DOUBLE PRECISION AS metragem_entregue
    , entregas.peso_entregue::DOUBLE PRECISION AS peso_entregue
    , CASE WHEN pedidos.tipo_produto = 1::TEXT THEN
				entregas.qtd_entregue*REPLACE(pedidos.valor_unitario_com_desconto, ',', '.')::DOUBLE PRECISION
				ELSE entregas.metragem_entregue*REPLACE(pedidos.valor_unitario_com_desconto, ',', '.')::DOUBLE PRECISION
			END AS valor_entregue
    , entregas.data_hora_entregue::TIMESTAMP
    , REPLACE(dev.qtd_devolvida, ',', '.')::DOUBLE PRECISION AS qtd_devolvida		
		, CASE WHEN dev.metragem_devolvida::DOUBLE PRECISION > 0 THEN
					CASE WHEN dev.metragem_devolvida::DOUBLE PRECISION >= entregas.metragem_entregue 
								THEN entregas.metragem_entregue::DOUBLE PRECISION * REPLACE(pedidos.valor_unitario_com_desconto, ',', '.')::DOUBLE PRECISION
								ELSE dev.metragem_devolvida::DOUBLE PRECISION * REPLACE(pedidos.valor_unitario_com_desconto, ',', '.')::DOUBLE PRECISION
								END
		ELSE CASE WHEN REPLACE(dev.qtd_devolvida, ',', '.')::DOUBLE PRECISION > entregas.qtd_entregue::DOUBLE PRECISION then
					entregas.qtd_entregue::DOUBLE PRECISION	* REPLACE(pedidos.valor_unitario_com_desconto, ',', '.')::DOUBLE PRECISION
					ELSE REPLACE(dev.qtd_devolvida, ',', '.')::DOUBLE PRECISION	* REPLACE(pedidos.valor_unitario_com_desconto, ',', '.')::DOUBLE PRECISION
					END
		END as venda_devolvido
        , CASE WHEN dev.metragem_devolvida::DOUBLE PRECISION > 0 THEN
					CASE WHEN dev.metragem_devolvida::DOUBLE PRECISION >= entregas.metragem_entregue 
								THEN entregas.metragem_entregue::DOUBLE PRECISION * REPLACE(pedidos.custo_unitario_produto, ',', '.')::DOUBLE PRECISION
								ELSE dev.metragem_devolvida::DOUBLE PRECISION * REPLACE(pedidos.custo_unitario_produto, ',', '.')::DOUBLE PRECISION
								END
		ELSE CASE WHEN REPLACE(dev.qtd_devolvida, ',', '.')::DOUBLE PRECISION > entregas.qtd_entregue::DOUBLE PRECISION then
					entregas.qtd_entregue::DOUBLE PRECISION	* REPLACE(pedidos.custo_unitario_produto, ',', '.')::DOUBLE PRECISION
					ELSE REPLACE(dev.qtd_devolvida, ',', '.')::DOUBLE PRECISION	* REPLACE(pedidos.custo_unitario_produto, ',', '.')::DOUBLE PRECISION
					END
		END as custo_devolvido
		, dev.data_devolucao::TIMESTAMP as data_devolucao
    , pedidos.endereco_gps
    , pedidos.unidade
    , pedidos.tipo_unidade
    , pedidos.cod_pedido AS qtd_pedidos
    , pedidos.cod_cliente AS qtd_clientes
    , pedidos.id_item::varchar(255) AS qtd_produtos
    , entregas.cod_romaneio AS qtd_romaneios
    , greatest(pedidos.data_hora_pedido::TIMESTAMP, entregas.data_hora_entregue::TIMESTAMP, dev.data_devolucao::TIMESTAMP) as last_updated
    , pedidos.vendedor    
FROM pedidos
LEFT JOIN (
	select
  tipo_unidade,
  unidade, 
  cod_pedido, 
  cod_item, 
  carga,
  tipo_entrega,
  tipo_veiculo,
  placa_veiculo,
  STRING_AGG(cod_romaneio, ',') as cod_romaneio, 
  sum(REPLACE(peso_entregue, ',', '.')::DOUBLE PRECISION) as peso_entregue
  	, sum(REPLACE(metragem_entregue, ',', '.')::DOUBLE PRECISION) as metragem_entregue
  	, sum(REPLACE(metragem_entregue_serie, ',', '.')::DOUBLE PRECISION) as metragem_entregue_serie
  	, sum(REPLACE(qtd_entregue, ',', '.')::DOUBLE PRECISION) as qtd_entregue
  	, MAX(data_hora_entregue) as data_hora_entregue
  	from entregas group by tipo_unidade, unidade, cod_pedido, cod_item, carga, tipo_entrega, tipo_veiculo, placa_veiculo
) entregas on (pedidos.id_item = concat(entregas.cod_pedido, entregas.cod_item) AND pedidos.unidade = entregas.unidade AND pedidos.tipo_unidade = entregas.tipo_unidade)
LEFT JOIN coes tipocoes on (tipocoes.nome = UPPER(TRIM(pedidos.coes)))
LEFT JOIN devolucoes dev ON (
	pedidos.cod_pedido = dev.cod_pedido AND 
	pedidos.cod_produto = dev.cod_produto AND 
	COALESCE(pedidos.medida_altura::DOUBLE PRECISION,0)::DOUBLE PRECISION = dev.altura::DOUBLE PRECISION AND 
	COALESCE(pedidos.medida_largura::DOUBLE PRECISION, 0)::NUMERIC = dev.largura::NUMERIC AND
	pedidos.unidade = dev.unidade AND
	pedidos.tipo_unidade = dev.tipo_unidade
)
WHERE
    UPPER(TRIM(pedidos.unidade)) != 'NAO INFORMADO'
    AND UPPER(TRIM(pedidos.tipo_unidade)) != 'NAO INFORMADO'
    AND pedidos.data_pedido >= '2023-01-01'		 
order by data_hora_pedido desc