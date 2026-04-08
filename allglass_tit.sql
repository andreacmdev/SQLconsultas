SELECT 
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
    rom.valor_entregue,
    saldo_cli.VLR_SALDO AS saldo_cliente,
    rom.DT_ROM,
    pedidos.ID_TP_PED,
    CASE pedidos.ID_TP_PED 
        WHEN 1 THEN 'Serie'
        WHEN 2 THEN 'Engenharia'
        WHEN 3 THEN 'Serviço'
        WHEN 5 THEN 'Laminado'
        ELSE 'Desconhecido'
    END AS tipo_pedido, 
    origem.DS_ORIGEM AS Origem
FROM mgpve01010 pedidos
LEFT JOIN mgpxo01010 origem
    ON origem.NU_PVE = pedidos.NU_PVE
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
-- 🔹 Romaneio: agregado dentro da subquery, sem NU_ROM solto
LEFT JOIN (
    SELECT 
        r11.NU_PVE,
        SUM(r11.VLR_FINAL_PROD) AS valor_entregue,
        MAX(r10.DT_ROM)         AS DT_ROM
    FROM mgrom01011 r11
    LEFT JOIN mgrom01010 r10
        ON r11.NU_ROM = r10.NU_ROM
    GROUP BY r11.NU_PVE
) rom
    ON pedidos.NU_PVE = rom.NU_PVE
-- 🔹 Saldo cliente: MAX(NU_SLD) desempata quando DT_LANCTO é igual
LEFT JOIN (
    SELECT t1.NU_CLI, t1.VLR_SALDO
    FROM mgcli01011 t1
    INNER JOIN (
        SELECT 
            NU_CLI,
            MAX(DT_LANCTO) AS dt_mais_recente,
            MAX(NU_SLD)    AS nu_sld_mais_recente
        FROM mgcli01011
        GROUP BY NU_CLI
    ) t2
        ON  t1.NU_CLI  = t2.NU_CLI
        AND t1.DT_LANCTO = t2.dt_mais_recente
        AND t1.NU_SLD    = t2.nu_sld_mais_recente
) saldo_cli
    ON pedidos.NU_CLI = saldo_cli.NU_CLI
WHERE 
    tit.ID_STAT_LANCTO = '1';