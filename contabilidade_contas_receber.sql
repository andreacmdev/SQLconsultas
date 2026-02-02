    select 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade, 
    '' as CNPJ_unidade,
    '' as razao_social,
     pedidos.NU_PVE AS cod_pedido,
    pedidos.NU_CLI AS cod_cliente,
    cli.NU_CPF_CNPJ ,
    cli.DS_CLI AS nome_cliente,
    ramo.DS_RAM,
    tit.ds_obs as descricao,
    pedidos.DS_OBS observacao,
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
    pedxtit.nu_cta as titulo,
    tit.VLR_TIT_ORIG AS valor_pendente,
    pedidos.VLR_TOT_PVE as valor_total_pedido,
    DATEDIFF(CURDATE(), pedidos.DT_PVE) AS tempo_pendente
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
WHERE 
    pedidos.DT_PVE > '2025-01-01' AND pedidos.DT_PVE <= '2025-12-31'
    AND tit.ID_STAT_LANCTO = '1'   