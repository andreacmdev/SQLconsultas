(select %(Tipo_Unidade)s AS Tipo_Unidade, %(Unidade)s AS Unidade,
    boletos.DS_BOLETO as nu_documento, 
    titulos.NU_CLI as cod_cliente,
    clientes.DS_CLI as nome_cliente, 
    boletos.ID_STATUS as status, 
    'boleto' as tipo_documento, 
    boletos.DT_EMISSAO as data_emissao,
    boletos.DT_VENCT as data_vencimento, 
    boletos.VLR_BOLETO as valor_titulo, 
    null as tipo, 
    CURRENT_DATE as last_updated
from mgcta01020 boletos 
left join (select NU_CLI, NU_CLT from mgcta01014 titulos group by NU_CLI, NU_CLT) titulos 
    on titulos.NU_CLT = boletos.NU_CLT_ORIGEM 
left join mgcli01010 clientes on clientes.NU_CLI = titulos.NU_CLI 
where boletos.ID_STATUS IN (1))
UNION ALL
(select %(Tipo_Unidade)s AS Tipo_Unidade, %(Unidade)s AS Unidade,
    boletos.DS_BOLETO as nu_documento, 
    titulos.NU_CLI as cod_cliente,
    clientes.DS_CLI as nome_cliente, 
    boletos.ID_STATUS as status, 
    'boleto' as tipo_documento, 
    boletos.DT_EMISSAO as data_emissao,
    boletos.DT_VENCT as data_vencimento, 
    boletos.VLR_BOLETO as valor_titulo, 
    null as tipo, 
    CURRENT_DATE as last_updated
from mgcta01020 boletos 
left join (select NU_CLI, NU_CLT from mgcta01014 titulos group by NU_CLI, NU_CLT) titulos 
    on titulos.NU_CLT = boletos.NU_CLT_ORIGEM 
left join mgcli01010 clientes on clientes.NU_CLI = titulos.NU_CLI 
left join mgdsf01010 dsf on (dsf.nu_dsf = boletos.nu_dsf) 
where boletos.ID_STATUS IN (4) and dsf.tp_dsf = 2)
UNION ALL
(Select %(Tipo_Unidade)s AS Tipo_Unidade, %(Unidade)s AS Unidade,
    'Financeiro' as nu_documento, 
    null, 
    null, 
    '1' as status, 
    'Dinheiro' as tipo_documento, 
    null, 
    null, 
    movcaixas.valor_saldo as saldo, 
    null,  
    caixas.DT_MCX as last_updated
from mgcxa01013 movcaixas 
inner join mgcxa01012 caixas ON caixas.NU_MCX = movcaixas.NU_MCX 
where movcaixas.TP_PAGTO = 1 AND caixas.NU_CXA = 1 
order by caixas.DT_MCX desc limit 1)
UNION ALL
(select %(Tipo_Unidade)s AS Tipo_Unidade, %(Unidade)s AS Unidade,
    cheques.nu_cheque as nu_documento, 
    titulos.NU_CLI as cod_cliente,
    clientes.DS_CLI as nome_cliente,
    cheques.ID_STATUS as status,
    'cheque' as tipo_documento,
    titulos.DT_EMISSAO as data_emissao,
    cheques.DT_CHEQUE as data_vencimento,
    cheques.VLR_CHEQUE as valor_titulo, 
    null as tipo, 
    CURRENT_DATE as last_updated 
from mgcta01016 cheques 
left join (select NU_CLI, NU_CLT, MAX(DT_EMISSAO) as dt_emissao from mgcta01014 titulos group by NU_CLI, NU_CLT) titulos 
    on titulos.NU_CLT = cheques.NU_CLT_ORIGEM 
left join mgcli01010 clientes on clientes.NU_CLI = titulos.NU_CLI 
where ID_STATUS IN (1))
UNION ALL
(select %(Tipo_Unidade)s AS Tipo_Unidade, %(Unidade)s AS Unidade,
    cheques.nu_cheque as nu_documento,  
    titulos.NU_CLI as cod_cliente, 
    clientes.DS_CLI as nome_cliente, 
    cheques.ID_STATUS as status, 
    'cheque' as tipo_documento, 
    titulos.DT_EMISSAO as data_emissao,
    cheques.DT_CHEQUE as data_vencimento,
    cheques.VLR_CHEQUE as valor_titulo,  
    null as tipo, 
    CURRENT_DATE as last_updated  
from mgcta01016 cheques  
left join (select NU_CLI, NU_CLT, MAX(DT_EMISSAO) as dt_emissao from mgcta01014 titulos group by NU_CLI, NU_CLT) titulos 
    on titulos.NU_CLT = cheques.NU_CLT_ORIGEM  
left join mgcli01010 clientes on clientes.NU_CLI = titulos.NU_CLI   
left join mgdsf01010 dsf on (dsf.nu_dsf = cheques.nu_dsf)   
where cheques.ID_STATUS IN (4))
UNION ALL
(select %(Tipo_Unidade)s AS Tipo_Unidade, %(Unidade)s AS Unidade,
    cartoes.ident_cartao as nu_documento, 
    titulos.NU_CLI as cod_cliente,
    clientes.DS_CLI as nome_cliente,
    cartoes.ID_STATUS as status,
    'cartao' as tipo_documento,
    titulos.DT_EMISSAO as data_emissao,
    cartoes.DT_RECEBTO as data_vencimento,
    cartoes.VLR_CARTAO as valor_titulo, 
    CASE car.TP_CAR 
        WHEN 1 then 'CRÉDITO' 
        WHEN 2 then 'DÉBITO' 
    END as tipo, 
    CURRENT_DATE as last_updated 
from mgcta01019 cartoes 
left join mgcar01010 car on car.NU_CAR = cartoes.NU_CAR 
left join (select NU_CLT, NU_CLI, MAX(DT_EMISSAO) as DT_EMISSAO from mgcta01014 group by NU_CLT, NU_CLI) titulos 
    on titulos.NU_CLT = cartoes.NU_CLT_ORIGEM 
left join mgcli01010 clientes on clientes.NU_CLI = titulos.NU_CLI 
where cartoes.ID_STATUS IN (1))
UNION ALL
(select %(Tipo_Unidade)s AS Tipo_Unidade, %(Unidade)s AS Unidade,
    a.NU_COC as cod,
    a.NU_CON as nu_documento, 
    contas.ds_con as nome_cliente,
    1 as status, 
    'Conta Interna' as tipo_documento, 
    null, 
    null,
    a.SLD_ATUAL as valor_titulo,
    null,
    a.DT_REF as last_updated 
from mgcon01011 a 
INNER JOIN (select NU_CON, MAX(con.NU_COC) as NU_COC, MAX(DT_REF) as maxdate from mgcon01011 con group by NU_CON) b 
    ON (b.NU_CON = a.NU_CON and b.maxdate = a.DT_REF and b.NU_COC = a.NU_COC) 
inner join mgcon01010 contas on contas.NU_CON = a.NU_CON  
where a.DT_REF > '2021-01-01' and contas.ID_ATIVO = 'S')
