select
%(Tipo_Unidade)s as Tipo_Unidade,
%(Unidade)s as Unidade,
DATE(pag.DT_LIB) as Data, 
TIME(pag.DT_LIB) as Horario,
SUM(pag.VLR_PAGO) as Valor,  
SUM(VLR_TROCO) as Troco, 
group_concat(pagtit.NU_PVE, '') as Pedidos
from mgcta01017 pag 
left join mgcta01014 tit on pag.NU_CLT = tit.NU_CLT 
left join mgpxt01010 pagtit on pagtit.NU_CTA = tit.NU_CTA
where date(pag.DT_LIB) >= '2023-01-01' and pag.TP_LANCTO = 'E'
group by pag.nu_clt 