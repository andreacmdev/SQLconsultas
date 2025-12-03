-- expedidos belga

select
	%(Tipo_Unidade)s AS Tipo_Unidade,
  	%(Unidade)s AS Unidade, 
    pedidos.NU_PVE as cod_pedido,
    produto.NU_PRO as cod_produto,
    pro.DS_COD_INTERNO as cod_interno_vendido, 
    pro.DS_PRO as desc_produto,
    produto.QT_PRO as qt_vendida,
    pedidos.DT_PVE as data_pedido,
    pedidos.VLR_FINAL as valor_final,
    rom.NU_ROM as romaneio,
    rom.DT_ROM as data_entrega
from mgpve01010 pedidos
left join mgpve01011 produto on pedidos.NU_PVE = produto.NU_PVE
left join mgrom01010 rom     on pedidos.NU_PVE = rom.NU_PVE
left join mgpro01010 pro     on produto.NU_PRO = pro.NU_PRO
where pedidos.ID_STATUS = '4'
  and pedidos.DT_PVE > '2025-01-01';