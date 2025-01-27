--box diario
SELECT 
    pc.tipo_unidade,
    pc.unidade,
    CASE
        WHEN pc.categoria = 'BOX PADRÃO' THEN '1.80'
        WHEN pc.categoria = 'BOX PADRÃO 1800' THEN '1.80'
        WHEN pc.categoria = 'BOX PADRÃO 1900' THEN '1.90'    
        ELSE pc.categoria 
    END AS padrao,
    pc.nome_produto,
    CASE
        WHEN LOWER(pc.nome_produto) LIKE '%fixo%' THEN 'FIXO'
        WHEN LOWER(pc.nome_produto) LIKE '%porta%' THEN 'PORTA'
        ELSE 'Outro'
    END AS tipo,
    REPLACE(pc.estoque_atual, ',', '.')::numeric AS estoque_atual,
    pc.classe,
    pc.subclasse,
    -- Extraindo o valor do meio
    CASE
        WHEN pc.nome_produto LIKE 'BOX%' THEN substring(pc.nome_produto FROM '[0-9]+')
        ELSE NULL
    END AS modelo
FROM  
    produtos_completos pc 
WHERE 
    pc.categoria LIKE '%BOX%' 
    AND REPLACE(pc.estoque_atual, ',', '.')::numeric = 0
    and pc.unidade = 'Alumiaco Recife'
GROUP BY
    pc.tipo_unidade, pc.unidade, pc.categoria, pc.nome_produto, pc.classe, pc.subclasse, pc.estoque_atual 
ORDER BY 
    pc.unidade;
