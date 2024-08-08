--devolução com valor
SELECT 
    d.* ,
    p.* ,
		CASE 
		    WHEN CAST(REPLACE(d.metragem_devolvida, ',', '.') AS NUMERIC) = 0 OR d.metragem_devolvida IS NULL THEN 
		         p.Valor
		    ELSE
		        (CAST(REPLACE(d.metragem_devolvida, ',', '.') AS NUMERIC) * p.ValorM2)
		END AS valor_devolvido
FROM devolucoes d
LEFT JOIN (
    SELECT 
        unidade ,
        cod_pedido ,
        cod_produto , 
        medida_altura , 
        medida_largura ,
        ROUND(SUM(REPLACE(valor_unitario_total_com_desconto, ',', '.')::NUMERIC), 2) AS Valor ,
        SUM(REPLACE(qtd_produto, ',', '.')::NUMERIC) AS qtd_produto , 
        ROUND(SUM(REPLACE(metragem_cobrada, ',', '.')::NUMERIC) , 2) AS m2 ,
        ROUND(
            CASE 
                WHEN SUM(REPLACE(metragem_cobrada, ',', '.')::NUMERIC) = 0 THEN 0
                ELSE SUM(REPLACE(valor_unitario_total_com_desconto, ',', '.')::NUMERIC) / SUM(REPLACE(metragem_cobrada, ',', '.')::NUMERIC)
            END, 2) AS ValorM2
    FROM pedidos
    GROUP BY 
        unidade, 
        cod_pedido, 
        cod_produto,  
        medida_altura, 
        medida_largura
) p 
ON d.unidade = p.unidade 
   AND p.cod_pedido = d.cod_pedido 
   AND p.cod_produto = d.cod_produto 
   AND COALESCE(p.medida_altura::TEXT, '0') = COALESCE(d.altura::TEXT, '0') 
   AND COALESCE(p.medida_largura::TEXT, '0') = COALESCE(d.largura::TEXT, '0')
WHERE d.data_devolucao::DATE BETWEEN '2024-06-01' AND '2024-06-30';