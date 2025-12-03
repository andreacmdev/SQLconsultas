SELECT 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade, 
    cliente.NU_CLI AS cod_cliente, 
    cliente.DS_CLI AS nome_cliente, 
    limite.LIM_BOL AS boleto, 
    limite.LIM_CART AS cartao, 
    limite.LIM_CHQ AS cheque, 
    limite.LIM_CHQ_TER AS cheque_terceiro
FROM mgcli01010 cliente
LEFT JOIN mgcli01016 limite 
    ON cliente.NU_CLI = limite.NU_CLI
WHERE 
    limite.LIM_BOL > '0' 
    OR limite.LIM_CART  > '0' 
    OR limite.LIM_CHQ  > '0' 
    OR limite.LIM_CHQ_TER  > '0' ;