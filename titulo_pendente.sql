select 
	%(Tipo_Unidade)s AS Tipo_Unidade,
  	%(Unidade)s AS Unidade, 
    pedidos.NU_PVE AS cod_pedido,
    pedidos.NU_CLI AS cod_cliente,
    cli.DS_CLI AS nome_cliente,
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
    pedidos.DT_PVE,
    pedxtit.nu_cta,
    tit.VLR_TIT_ORIG AS valor_pendente,
    pedidos.VLR_TOT_PVE,
    DATEDIFF(CURDATE(), pedidos.DT_PVE) AS tempo_pendente,
    rom.valor_entregue ,
    saldo_cli.VLR_SALDO AS saldo_cliente,
    dtrom.DT_ROM,
    pedidos.ID_TP_PED ,
    TIT.DT_PAGTO,
    case pedidos.ID_TP_PED 
        when 1 then 'Serie'
        when 2 then 'Engenharia'
        when 3 then 'Serviço'
        when 5 then 'Laminado'
        else 'Desconhecido'
   end as tipo_pedido
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
-- 🔹 Soma do valor entregue por pedido
LEFT JOIN (
    SELECT 
        NU_ROM ,
        NU_PVE,
        SUM(VLR_FINAL_PROD) AS valor_entregue
    FROM mgrom01011
    GROUP BY NU_PVE
) rom
    ON pedidos.NU_PVE = rom.NU_PVE
left join mgrom01010 dtrom on rom.NU_ROM = dtrom.NU_ROM
LEFT JOIN (
    SELECT 
        t1.NU_CLI,
        t1.VLR_SALDO
    FROM mgcli01011 t1
    INNER JOIN (
        SELECT 
            NU_CLI,
            MAX(DT_LANCTO) AS dt_mais_recente
        FROM mgcli01011
        GROUP BY NU_CLI
    ) t2
    ON  t1.NU_CLI = t2.NU_CLI
    AND t1.DT_LANCTO = t2.dt_mais_recente
) saldo_cli
    ON pedidos.NU_CLI = saldo_cli.NU_CLI
WHERE 
    pedidos.DT_PVE >= '2025-01-01'
    AND tit.ID_STAT_LANCTO in ('1', '2');