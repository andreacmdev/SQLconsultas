select 
%(Tipo_Unidade)s as Tipo_Unidade,
%(Unidade)s as Unidade,  
con.DS_CON as Conta,
SUM(dep.VLR_DEPOSITO) as Valor
from mgcta01021 dep 
left join mgcon01010 con on con.NU_CON = dep.NU_CON 
where PIX = 'S' and DT_REF between '2024-05-01' and '2024-05-31'
group by con.DS_CON 
