SELECT
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,  
    pedidos.NU_PVE AS cod_pedido,
    clientes.DS_CLI AS nome_cliente,
    pedidos.DT_PVE AS data_pedido,
    trans.DT_ENV as data_transmissao,
    usu_trans.DS_LOGIN as usuario_transmissão,
    GROUP_CONCAT(DISTINCT romaneios.NU_ROM ORDER BY romaneios.NU_ROM SEPARATOR ', ') AS romaneio,
    romaneios.NU_ROM_EXTERNO as romaneio_externo,
    rr.DT_RECEBTO ,    
    usu.DS_LOGIN as usuario_recebimento
FROM mgpve01010 pedidos
INNER JOIN mgcli01010 clientes
    ON clientes.NU_CLI = pedidos.NU_CLI
LEFT JOIN mgrom01011 itens_romaneio
    ON itens_romaneio.NU_PVE = pedidos.NU_PVE
LEFT JOIN mgrom01010 romaneios
    ON romaneios.NU_ROM = itens_romaneio.NU_ROM
   AND romaneios.ID_TP_ROM = 4
left join recebimento_romaneios rr on rr.NU_ROM = itens_romaneio.NU_ROM 
left join mgusu01010 usu on rr.NU_USU = usu.NU_USU 
left join mgpce01010 trans on pedidos.NU_PVE = trans.NU_PVE 
left join mgpro01010 pro on itens_romaneio.NU_PRO = pro.NU_PRO 
left join mgcat01010 cat on pro.NU_CAT = cat.NU_CAT 
LEFT JOIN mgusu01010 usu_trans ON trans.NU_USU = usu_trans.NU_USU
WHERE pedidos.DT_PVE > '2026-01-01'
and cat.DS_CAT like '%TEMPER%'
GROUP BY
    pedidos.NU_PVE,
    clientes.DS_CLI,
    pedidos.DT_PVE