SELECT  
      %(Tipo_Unidade)s AS Tipo_Unidade
    , %(Unidade)s AS Unidade,
    CASE        
        WHEN titulos.COD_LANCTO = '1' AND titulos.TITULO_AVULSO = 'S' THEN 'Entrada Avulsa'           
        WHEN titulos.COD_LANCTO = '1' THEN 'Entrada'     
        WHEN titulos.COD_LANCTO = '2' THEN 'Saída'    
    END AS tipo_de_lancamento,    
    formas.NU_CLT AS chave,    
    CASE TP_PAGTO           
        WHEN 1 AND formas.NU_CON IS NULL THEN 'Dinheiro'            
        WHEN 1 AND formas.NU_CON IS NOT NULL THEN 'Conta Interna'          
        WHEN 2 THEN 'Cheque'        
        WHEN 3 THEN 'Cartão'     
        WHEN 4 THEN 'Saldo'     
        WHEN 5 THEN 'Outros'     
        WHEN 6 THEN 'Boleto'     
        WHEN 7 THEN 'Depósito'     
        WHEN 8 THEN 'Duplicata'     
        WHEN 9 THEN 'Saldo de Outro Cliente'      
        ELSE 'Não Determinado'   
    END AS forma_pagamento,    
    titulos.NU_DOCTO as documento, 
    formas.VLR_DLT AS valor_pago,     
    titulos.DT_PAGTO AS data_pagamento,   
    titulos.DT_CANC as data_cancelamento, 
    CASE 
        WHEN TP_PAGTO = 3 THEN cartao_info.cartao
        ELSE COALESCE(contas.DS_CON, contasDep.DS_CON) 
    END AS nome_conta,
    coalesce(contas.NU_AGENCIA, contasDep.NU_AGENCIA) AS agencia,    
    coalesce(contas.NU_CONTA, contasDep.NU_CONTA) AS conta     ,
    titulos.DS_OBS_CANC 
FROM mgcta01018 formas     
LEFT JOIN mgcon01010 contas ON contas.NU_CON = formas.NU_CON          
LEFT JOIN mgcta01014 titulos ON titulos.NU_CLT = formas.NU_CLT      
LEFT JOIN mgcta01021 DepxTit ON DepxTit.NU_DLT = formas.NU_DLT    
LEFT JOIN mgcon01010 contasDep ON contasDep.NU_CON = DepxTit.NU_CON      
LEFT JOIN (
    SELECT 
        NU_DLT,
        dsf.NU_CON AS conta_cartao,
        cartoes.DS_CAR AS cartao,
        SUM(VLR_CARTAO) AS valor_cartao
    FROM mgcta01019 recebimentos
    LEFT JOIN mgdsf01010 dsf ON dsf.NU_DSF = recebimentos.NU_DSF
    LEFT JOIN mgcar01010 cartoes ON recebimentos.NU_CAR = cartoes.NU_CAR
    GROUP BY NU_DLT, dsf.NU_CON, cartoes.DS_CAR
) cartao_info ON cartao_info.NU_DLT = formas.NU_DLT
WHERE titulos.ID_STAT_LANCTO = '4'  
  AND titulos.COD_LANCTO = '1'  
  AND titulos.DT_PAGTO < DATE_FORMAT(CURDATE(), '%Y-%m-01')  -- Pagamento no mês anterior ou antes
  AND titulos.DT_CANC >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
GROUP BY                  
    formas.NU_CLT,   
    CASE TP_PAGTO          
        WHEN 1 AND formas.NU_CON IS NULL THEN 'Dinheiro'           
        WHEN 1 AND formas.NU_CON IS NOT NULL THEN 'Conta Interna'          
        WHEN 2 THEN 'Cheque'        
        WHEN 3 THEN 'Cartão'     
        WHEN 4 THEN 'Saldo'     
        WHEN 5 THEN 'Outros'     
        WHEN 6 THEN 'Boleto'     
        WHEN 7 THEN 'Depósito'     
        WHEN 8 THEN 'Duplicata'     
        WHEN 9 THEN 'Saldo de Outro Cliente'     
        ELSE 'Não Determinado'     
    END   
ORDER BY formas.NU_CLT DESC; 