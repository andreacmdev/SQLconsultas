-- docs em deposito
(select  
    boletos.DS_BOLETO as nu_documento, 
    titulos.NU_CLI as cod_cliente,
    clientes.DS_CLI as nome_cliente, 
    boletos.ID_STATUS as status, 
    'EM DEPOSITO' AS status_documento,
    'boleto' as tipo_documento, 
    boletos.DT_EMISSAO as data_emissao,
    boletos.DT_VENCT as data_vencimento,
    boletos.VLR_BOLETO as valor_titulo,
    null as tipo, 
    CURRENT_DATE as last_updated,
    dsf.NU_DSF,
    con.DS_CON 
from mgcta01020 boletos 
left join (
    select NU_CLI, NU_CLT 
    from mgcta01014 titulos 
    group by NU_CLI, NU_CLT
) titulos on titulos.NU_CLT = boletos.NU_CLT_ORIGEM 
left join mgcli01010 clientes on clientes.NU_CLI = titulos.NU_CLI 
left join mgdsf01010 dsf on dsf.nu_dsf = boletos.nu_dsf 
left join mgcon01010 con on con.NU_CON = dsf.NU_CON 
where boletos.ID_STATUS = 4 -- em deposito
  and dsf.tp_dsf = 2 
  and clientes.DS_CLI is not null) 
UNION ALL
-- Cheques
(select 
    cheques.nu_cheque as nu_documento, 
    titulos.NU_CLI as cod_cliente,
    clientes.DS_CLI as nome_cliente, 
    cheques.ID_STATUS as status, 
    'EM DEPOSITO' AS status_documento,
    'cheque' as tipo_documento, 
    titulos.DT_EMISSAO as data_emissao,
    cheques.DT_CHEQUE as data_vencimento,
    cheques.VLR_CHEQUE as valor_titulo, 
    null as tipo, 
    CURRENT_DATE as last_updated,
    dsf.NU_DSF,
    con.DS_CON 
from mgcta01016 cheques 
left join (
    select NU_CLI, NU_CLT, MAX(DT_EMISSAO) as dt_emissao 
    from mgcta01014 titulos 
    group by NU_CLI, NU_CLT
) titulos on titulos.NU_CLT = cheques.NU_CLT_ORIGEM 
left join mgcli01010 clientes on clientes.NU_CLI = titulos.NU_CLI 
left join mgdsf01010 dsf on dsf.nu_dsf = cheques.nu_dsf 
left join mgcon01010 con on con.NU_CON = dsf.NU_CON
where cheques.ID_STATUS = 4 -- em depósito
  and clientes.DS_CLI is not null)