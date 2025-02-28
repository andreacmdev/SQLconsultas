select 
Mes,
Banco,
Conta,
Info_Agencia,
Info_Conta,
Cartao,
SUM(Valor)
from (
select 
month(tit.DT_EMISSAO) as Mes,
banco.DS_BAN as Banco,
conta.DS_CON as Conta,
conta.NU_AGENCIA as Info_Agencia,
conta.NU_CONTA as Info_Conta,
car.DS_CAR as Cartao,
cartao.IDENT_CARTAO as Identificacao_cartao,
cartao.VLR_CARTAO as Valor
from mgcta01019 cartao
left join mgcar01010 car on cartao.NU_CAR = car.NU_CAR 
left join mgdsf01010 dsf on dsf.NU_DSF = cartao.NU_DSF 
left join mgcon01010 conta on conta.NU_CON = dsf.NU_CON 
left join mgban01010 banco on banco.NU_BAN = dsf.NU_BAN 
left join mgcta01018 doc on doc.NU_DLT = cartao.NU_DLT 
left join 
(
select 
NU_CLT,
max(DT_EMISSAO) as DT_EMISSAO
from mgcta01014
group by nu_clt
) tit on tit.NU_CLT = cartao.NU_CLT_ORIGEM 
where  date(tit.DT_EMISSAO) between '2024-04-01' and '2024-04-31' and cartao.ID_STATUS <> '7'
) x group by
Mes,
Banco,
Conta,
Info_Agencia,
Info_Conta,
Cartao