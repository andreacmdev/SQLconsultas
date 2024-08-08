--box diário
SELECT 
    pc.tipo_unidade,
    pc.unidade,
    case
    	when pc.categoria = 'BOX PADRÃO' then '1.80'
    	when pc.categoria = 'BOX PADRÃO 1800' then '1.80'
    	when pc.categoria = 'BOX PADRÃO 1900' then '1.90'    
    	else pc.categoria 
    	end as padrao,
    pc.nome_produto,
	pc.tipo,
    REPLACE(pc.estoque_atual, ',', '.')::numeric AS estoque_atual,
    pc.classe,
    pc.subclasse
FROM  
    produtos_completos pc 
WHERE 
    pc.categoria LIKE 'BOX%' AND REPLACE(pc.estoque_atual, ',', '.')::numeric = 0
ORDER BY 
    pc.tipo_unidade, pc.unidade, padrao , tipo, pc.classe, pc.subclasse, pc.estoque_atual ,pc.nome_produto;