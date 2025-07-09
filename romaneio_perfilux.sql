select
%(Tipo_Unidade)s AS Tipo_Unidade,
%(Unidade)s AS Unidade,   
rom.NU_ROM as romaneio,
rom.DT_ROM as data_romaneio,
rom.NU_PVE as pedido,
romaneio.DS_PRO as produto,
romaneio.DS_CLi as cliente,
romaneio.NU_PVE as cod_pedido,
romaneio.VLR_FINAL_PROD as valor ,
romaneio.DS_OBS as observacao,
romaneio.QT_PRO as qtd_produto ,
rom.TIPO_ENTREGA,
rom.TIPO_VEICULO,
rom.ROTA_LOGISTICA
from mgrom01010 rom 
left join mgrom01011 romaneio on rom.nu_rom = romaneio.NU_ROM
where rom.DT_ROM >= '2025-05-15'