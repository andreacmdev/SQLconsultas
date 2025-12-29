SELECT 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade, 
       boletos.DS_BOLETO as nu_documento,
    boletos.DT_EMISSAO as data_emissao,
    case 
        when boletos.ID_STATUS  = 1 then 'FINANCEIRO'
        when boletos.ID_STATUS = 4 then 'A LIQUIDAR'
        when boletos.ID_STATUS = 2 then 'DEVOLVIDO PENDENTE'
        when boletos.ID_STATUS = 3 then 'DEVOLVIDO PAGO'
        when boletos.ID_STATUS = 5 then 'LIQUIDADO'
        when boletos.ID_STATUS = 7 then 'ESTORNADO'
        else 'OUTRO'
    end as status,
    boletos.DT_VENCT as data_vencimento,
    boletos.VLR_BOLETO as valor_titulo,
    titulos.NU_CLI as cod_cliente,
    clientes.DS_CLI as nome_cliente,
    clientes.APEL_FANT ,
    clientes.NU_CPF_CNPJ as cnpj,
    dsf.NU_DSF as n_dsf,
   dsf.TP_DSF,
    case 
        when dsf.TP_DSF = 0 then 'ANTECIPACAO'
        when dsf.TP_DSF = 1 then 'CUSTODIA'
        when dsf.TP_DSF = 2 then 'DEPOSITO'
        else 'DEPOSITO'
    end as tipo_dsf,
    boletos.Pendente_Tipo,
    'boleto' as tipo_documento,
    dsf.NU_BAN as cod_banco,
    dsf.NU_CON as cod_conta,
    con.DS_CON as conta,
    banco.DS_BAN as inst_financeira,
    titulos.DS_CPG as descricao,
    titulos.ds_obs as observacao
from mgcta01020 boletos
left join (
    select NU_CLI, NU_CLT , nu_cta, DS_CPG, ds_obs 
    from mgcta01014 titulos 
    group by NU_CLI, NU_CLT
) titulos on titulos.NU_CLT = boletos.NU_CLT_ORIGEM 
left join mgcli01010 clientes on clientes.NU_CLI = titulos.NU_CLI 
left join mgdsf01010 dsf on dsf.nu_dsf = boletos.nu_dsf 
left join mgcon01010 con on con.NU_CON = dsf.NU_CON 
left join mgban01010 banco on dsf.NU_BAN = banco.NU_BAN
where boletos.ID_STATUS in ('1', '2', '3', '4', '6', '7')