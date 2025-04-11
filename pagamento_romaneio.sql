-- pagamento por romaneio
select 
	%(Tipo_Unidade)s AS Tipo_Unidade,
	%(Unidade)s AS Unidade,
	tit.nu_cta as titulo,
	tit.DT_PAGTO as data_pagamento,
	tit.NU_CLI as cod_cliente,
	cli.DS_CLI as nome_cliente,
	tit.DS_CPG as descricao,
	rom.DT_ROM as data_entrega,
	tit.NU_ROM as romaneio
from mgcta01014 tit
left join mgcli01010 cli on tit.NU_CLI = cli.NU_CLI
left join mgrom01010 rom on tit.NU_ROM = rom.NU_ROM
where tit.DT_PAGTO = CURRENT_DATE - 1
and rom.DT_ROM is not null