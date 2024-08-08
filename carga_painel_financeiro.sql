-- Consulta ajustada para agregar dados
SELECT 
    tipo_unidade,
    unidade,
    CASE 
        WHEN tipo_documento = 'cartao' THEN 'PAGAMENTO_CARTAO'
        WHEN tipo_documento = 'Dinheiro' THEN 'PAGAMENTO_DINHEIRO'
        WHEN tipo_documento = 'cheque' THEN 'PAGAMENTO_CHEQUE'
        WHEN tipo_documento = 'boleto' THEN 'PAGAMENTO_BOLETO'
        ELSE nome_cliente
    END AS nome_cliente,
    CASE 
        WHEN tipo_documento IN ('cartao', 'Dinheiro', 'cheque', 'boleto') THEN tipo_documento
        ELSE 'Conta Interna'
    END AS tipo_documento,
    SUM(CAST(REPLACE(valor_titulo, ',', '.') AS NUMERIC)) AS valor_total,
    tipo,
    MAX(last_updated) AS last_updated
FROM 
    painel_financeiro
where 
	unidade = 'Alumiaco Recife'
GROUP BY 
    tipo_unidade,
    unidade,
    CASE 
        WHEN tipo_documento = 'cartao' THEN 'PAGAMENTO_CARTAO'
        WHEN tipo_documento = 'Dinheiro' THEN 'PAGAMENTO_DINHEIRO'
        WHEN tipo_documento = 'cheque' THEN 'PAGAMENTO_CHEQUE'
        WHEN tipo_documento = 'boleto' THEN 'PAGAMENTO_BOLETO'
        ELSE nome_cliente
    END,
    CASE 
        WHEN tipo_documento IN ('cartao', 'Dinheiro', 'cheque', 'boleto') THEN tipo_documento
        ELSE 'Conta Interna'
    END,
    tipo
ORDER BY 
    unidade;