select 
	%(Tipo_Unidade)s AS Tipo_Unidade,
  	%(Unidade)s AS Unidade, 
    '' as CNPJ_unidade,
    '' as razao_social,
  pedidos.NU_PVE AS cod_pedido,
    pedidos.NU_CLI AS cod_cliente,
    cli.NU_CPF_CNPJ as cpf_cnpj_cliente,
    cli.DS_CLI AS nome_cliente,
    tit.DS_OBS as descricao,
    pedidos.DS_OBS as observacao,
    ramo.DS_RAM,
    pedidos.ID_STATUS,
     CASE pedidos.ID_STATUS
            WHEN 1 THEN 'Aberto' 
            WHEN 2 THEN 'Em Separacao' 
            WHEN 4 THEN 'Finalizado' 
            WHEN 6 THEN 'Cancelado' 
            WHEN 8 THEN 'Em Producao'
            WHEN 9 THEN 'Pend. Liberacao Financeira'
            ELSE 'Orcamento' 
        END AS StatusPedido,
    cond.DS_CPG AS condicao_pagamento,
    pedidos.DT_PVE as data_pedido,
    pedxtit.nu_cta as titulos,
    tit.VLR_PAGO AS valor_recebido,
    pedidos.VLR_TOT_PVE as valor_pedido,
    tit.DT_PAGTO as data_recebimento,
    CASE formas.TP_PAGTO       
        WHEN 1 and formas.NU_CON is null THEN 'Dinheiro'       
        WHEN 1 and formas.NU_CON is not null THEN 'Conta Interna'    
        WHEN 2 THEN 'Cheque' 
        WHEN 3 THEN 'Cartao' 
        WHEN 4 THEN 'Saldo' 
        WHEN 5 THEN 'Outros' 
        WHEN 6 THEN 'Boleto' 
        WHEN 7 THEN 'Deposito' 
        WHEN 8 THEN 'Duplicata' 
        WHEN 9 THEN 'Saldo de Outro Cliente' 
        ELSE 'Nao Determinado' 
    END AS forma_recebimento ,
    con.DS_CON as nome_conta,
    banco.DS_BAN as banco,
    con.NU_AGENCIA as agencia,
    con.NU_CONTA as conta
FROM mgpve01010 pedidos
LEFT JOIN mgcpg01010 cond 
    ON pedidos.NU_CPG = cond.NU_CPG
LEFT JOIN mgcli01010 cli 
    ON pedidos.NU_CLI = cli.NU_CLI
LEFT JOIN mgpxt01010 pedxtit 
    ON pedidos.NU_PVE = pedxtit.NU_PVE
LEFT JOIN mgcta01014 tit 
    ON pedxtit.nu_cta = tit.nu_cta
LEFT JOIN mgram01010 ramo 
    ON cli.NU_RAM = ramo.NU_RAM
left join mgcta01018 formas 
    on tit.NU_CLT = formas.NU_CLT
left join mgcon01011 conta
    on conta.nu_cta = tit.nu_cta 
left join mgcon01010 con
    on con.NU_CON = conta.NU_CON
left join mgban01010 banco
    on con.NU_BAN = banco.NU_BAN
WHERE 
    pedidos.DT_PVE >= '2025-01-01' and pedidos.DT_PVE <= '2025-12-31'
    AND tit.ID_STAT_LANCTO = '2'