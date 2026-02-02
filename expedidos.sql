SELECT
    ped.NU_PVE   AS CodPedido,
    ip.NU_DPV    AS CodItem,
    rom.NU_ROM   AS CodRomaneio,
    rom.DT_ROM   AS DataEntrega,
    itens.QT_PRO AS QtdEntregue,
    -- metragem entregue
    CASE 
        WHEN pro.TP_PROD = 1 
            THEN pro.FAT_CONV1 * itens.QT_PRO
        ELSE itens.qt_metragcob
    END AS MetragemEntregue,
    itens.peso * itens.QT_PRO AS PesoEntregue,
    -- valor venda com desconto (mesma lógica original)
    ((ip.VLR_PRO * (100 - ip.alq_desc)) / 100) AS ValorVendaProdutoComDesconto,
    -- VALOR ENTREGUE (mesma regra do script grande)
    IF(
        ip.QT_PRO = itens.QT_PRO,
        ip.VLR_TOTAL,
        IF(
            pro.TP_PROD = 1,
            itens.QT_PRO * ((ip.VLR_PRO * (100 - ip.alq_desc)) / 100),
            itens.qt_metragcob * ((ip.VLR_PRO * (100 - ip.alq_desc)) / 100)
        )
    ) AS ValorEntregue
FROM mgrom01011 itens
INNER JOIN mgrom01010 rom 
    ON rom.NU_ROM = itens.NU_ROM
INNER JOIN mgpro01010 pro 
    ON pro.NU_PRO = itens.NU_PRO
INNER JOIN mgpve01011 ip 
    ON ip.NU_DPV = itens.NU_DPV
INNER JOIN mgpve01010 ped 
    ON ped.NU_PVE = ip.NU_PVE
WHERE rom.ID_TP_ROM = 2
  AND rom.DT_ROM >= '2025-01-01'
  AND rom.DT_ROM <  '2025-02-01';
