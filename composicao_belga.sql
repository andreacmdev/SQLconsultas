-- composicao belga

select
	%(Tipo_Unidade)s AS Tipo_Unidade,
  	%(Unidade)s AS Unidade, b.DS_COD_INTERNO as cod_interno, b.DS_PRO as Prod_Principal, a.NU_KIT as Cod_Kit, g.DS_COD_INTERNO as Cod_Pro_Kit, g.DS_PRO as Comp, a.QTDE_KIT as Quant_Kit, h.DS_CUM as Unid_Kit, b.NU_PRO   from mgpro01011 a
left join mgpro01010 b on a.NU_PRO=b.NU_PRO
left join mgcat01010 c on b.NU_CAT=c.NU_CAT
left join mgclp01010 d on b.NU_CLP=d.NU_CLP
left join mgscp01010 e on b.NU_SCP=e.NU_SCP
left join mgcum01010 f on b.NU_CUM=f.NU_CUM
left join mgpro01010 g on a.NU_PRK=g.NU_PRO
left join mgcum01010 h on g.NU_CUM=h.NU_CUM
