-- expedidos
SELECT 
    eg.tipo_unidade ,
	eg.unidade,
    eg.cod_pedido,
	eg.valor_entregue ,
	eg.custo_entregue ,
	eg.qtd_entregue ,
	eg.data_hora_entregue 
FROM 
    entregas_geral eg 
where
	tipo_unidade = 'Bodinho' and 
	eg.data_hora_entregue ::date BETWEEN '2024-01-01' AND '2024-01-31'
order by 
	unidade;