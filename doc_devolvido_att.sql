select 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   
  boletos.DS_BOLETO as nu_documento,
  boletos.DT_EMISSAO as data_emissao,
  'Devolvido Pendente' as status, 
  boletos.DT_VENCT as data_vencimento,
  boletos.VLR_BOLETO as valor_titulo,
  titulos.NU_CLI as cod_cliente,
  clientes.DS_CLI as nome_cliente,
  dsf.NU_DSF as n_dsf,
  dsf.TP_DSF as tipo_dsf,
  boletos.Pendente_Tipo,
  'boleto' as tipo_documento,
  dsf.NU_BAN as cod_banco,
  dsf.NU_CON as cod_conta,
  banco.DS_BAN as inst_financeira
from mgcta01020 boletos
left join (
  select NU_CLI, NU_CLT 
  from mgcta01014 titulos 
  group by NU_CLI, NU_CLT
) titulos on titulos.NU_CLT = boletos.NU_CLT_ORIGEM 
left join mgcli01010 clientes on clientes.NU_CLI = titulos.NU_CLI 
left join mgdsf01010 dsf on dsf.nu_dsf = boletos.nu_dsf 
left join mgcon01010 con on con.NU_CON = dsf.NU_CON 
left join mgban01010 banco on dsf.NU_BAN = banco.NU_BAN
where boletos.ID_STATUS = '2' 
union all
select 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   
  cheque.NU_CHEQUE as nu_documento,
  null as data_emissao,
  'Devolvido Pendente' as status, 
  null as data_vencimento,
  cheque.VLR_CHEQUE as valor_titulo,
  titulos.NU_CLI as cod_cliente,
  clientes.DS_CLI as nome_cliente,
  dsf.NU_DSF as n_dsf,
  dsf.TP_DSF as tipo_dsf,
  null as Pendente_Tipo,
  'cheque' as tipo_documento,
  dsf.NU_BAN as cod_banco,
  dsf.NU_CON as cod_conta,
  banco.DS_BAN as inst_financeira
from mgcta01016 cheque
left join (
  select NU_CLI, NU_CLT 
  from mgcta01014 titulos 
  group by NU_CLI, NU_CLT
) titulos on titulos.NU_CLT = cheque.NU_CLT_ORIGEM 
left join mgcli01010 clientes on clientes.NU_CLI = titulos.NU_CLI 
left join mgdsf01010 dsf on dsf.nu_dsf = cheque.nu_dsf 
left join mgcon01010 con on con.NU_CON = dsf.NU_CON 
left join mgban01010 banco on dsf.NU_BAN = banco.NU_BAN 
where cheque.ID_STATUS = 2 
  and clientes.DS_CLI is not null
