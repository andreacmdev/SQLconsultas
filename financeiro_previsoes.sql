SELECT    
    %(Tipo_Unidade)s AS Tipo_Unidade,
	%(Unidade)s AS Unidade,   
    titulos.nu_cta AS Titulo,   
    'Despesa' AS Tipo,   
    titulos.DT_EMISSAO AS DataEmissao,   
    titulos.DT_VENCTO AS DataVencimento,   
    CASE    
        WHEN titulos.ID_STAT_LANCTO = 5 THEN 'PREVISAO MANUAL'   
        WHEN titulos.ID_STAT_LANCTO = 1 THEN 'PENDENTE'  
        WHEN titulos.ID_STAT_LANCTO = 2 THEN 'PAGO'  
        WHEN titulos.ID_STAT_LANCTO = 3 THEN 'CANCELADO'
        WHEN titulos.ID_STAT_LANCTO = 6 THEN 'PREVISAO AUTOMATICA'
    END AS Situacao,     
    CASE    
        WHEN titulos.NU_FOR > 0 THEN fornecores.DS_FOR   
        WHEN titulos.NU_COL > 0 THEN colaborador.DS_COL   
    END AS FornecedorColaborador,   
    titulos.DS_CPG AS Descricao,
    titulos.VLR_TIT_ORIG AS ValorTitulo,   
    centrocusto.DS_CCU AS CentroCusto,    
    planoconta.DS_CPC AS PlanoConta,    
    classificacao.DS_TPD AS Classificacao,   
    titulos.NU_DOCTO AS Documento,   
    titulos.DS_OBS AS Observacao,   
    usu.NOM_USU AS Usuario,
    CASE 
        WHEN formas.TP_PAGTO = 1 AND formas.NU_CON IS NULL THEN 'Dinheiro'     
        WHEN formas.TP_PAGTO = 1 AND formas.NU_CON IS NOT NULL THEN 'Conta Interna'    
        WHEN formas.TP_PAGTO = 2 THEN 'Cheque'    
        WHEN formas.TP_PAGTO = 3 THEN 'Cartao' 
        WHEN formas.TP_PAGTO = 4 THEN 'Saldo' 
        WHEN formas.TP_PAGTO = 5 THEN 'Outros' 
        WHEN formas.TP_PAGTO = 6 THEN 'Boleto' 
        WHEN formas.TP_PAGTO = 7 THEN 'Deposito' 
        WHEN formas.TP_PAGTO = 8 THEN 'Duplicata' 
        WHEN formas.TP_PAGTO = 9 THEN 'Saldo de Outro Cliente' 
        ELSE 'Nao Determinado' 
    END AS forma_pagamento   
FROM mgcta01014 titulos   
LEFT JOIN mgtxc01010 titConta ON titulos.NU_CTA = titConta.NU_CTA
LEFT JOIN mgccu01010 centrocusto ON titConta.NU_CCU = centrocusto.NU_CCU
LEFT JOIN mgcpc01010 planoconta ON titConta.NU_CPC = planoconta.NU_CPC
LEFT JOIN mgfor01010 fornecores ON titulos.NU_FOR = fornecores.NU_FOR   
LEFT JOIN mgcol01010 colaborador ON colaborador.NU_COL = titulos.NU_COL      
LEFT JOIN mgtpd01010 classificacao ON classificacao.NU_TPD = titulos.NU_TPD    
LEFT JOIN mgusu01010 usu ON usu.NU_USU = titulos.NU_USU    
LEFT JOIN mgcta01017 pagamentos ON titulos.NU_CLT = pagamentos.NU_CLT
LEFT JOIN mgcta01018 formas ON pagamentos.NU_CLT = formas.NU_CLT  
WHERE
    titulos.ID_STAT_LANCTO IN (5, 1, 6)  
    AND titulos.COD_LANCTO = 2
    AND titulos.DT_VENCTO BETWEEN '2025-02-01' and '2025-02-07'