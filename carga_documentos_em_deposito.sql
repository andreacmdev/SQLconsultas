SELECT 
    tipo_unidade,
    unidade,
    nome_cliente,
    CASE 
        WHEN tipo_documento IN ('cartao', 'Dinheiro', 'cheque', 'boleto') THEN tipo_documento
        ELSE 'Conta Interna'
    END AS tipo_documento,
    CASE 
        WHEN status = '4' THEN 'EM DEPOSITO'
        ELSE 'STATUS_DESCONHECIDO'
    END AS status_documento,
    valor_titulo ,
    nu_documento,  
    TO_CHAR(TO_DATE(SUBSTRING(pf.data_emissao, 1, 10), 'YYYY/MM/DD'), 'YYYY-MM-DD') AS data_emissao,
    TO_CHAR(TO_DATE(SUBSTRING(pf.data_vencimento, 1, 10), 'YYYY/MM/DD'), 'YYYY-MM-DD') AS data_vencimento
FROM 
    painel_financeiro pf
WHERE
    tipo_documento IN ('boleto', 'cheque')
    AND status = '4';