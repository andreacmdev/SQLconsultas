
select 
%(Tipo_Unidade)s as Tipo_Unidade,
%(Unidade)s as Unidade,  
MIX, 
Chapa, 
Classe, 
Subclasse, 
SUM(PERDA_CHAPA) as Perda, 
SUM(AREA_CHAPA) as Area  
from (
select 
	filtro.NU_DPL,
	filtro.mix,
	PERDA.DS_SCP as Subclasse,
	PERDA.DS_CLP as Classe,
	PERDA.PERDA_CHAPA,
	concat(PERDA.ALTURA_CH,'x',PERDA.LARGURA_CH) as "CHAPA",
	round(PERDA.ALTURA_CH*PERDA.LARGURA_CH/1000000,2) as "AREA_CHAPA"
from(
	select 
		group_concat(distinct(categoria.DS_CAT)) as "mix",
		peca.NU_DPL
		from mgplc01012 peca
			left join mgplc01011 chapa on (chapa.NU_DPL = peca.NU_DPL)
			left join mgplc01010 plano on (plano.NU_PLC = chapa.NU_PLC)
			left join mgorf01011 ordem on (peca.NU_PECA = ordem.NU_PECA)
			left join mgpro01010 produto on (produto.NU_PRO = ordem.NU_PRO)
			left join mgcat01010 categoria on (categoria.NU_CAT = produto.NU_CAT)
		where plano.DT_PLC between date_add(date(%(DataInicial)s), interval - 1 month) and date_add(date(%(DataFinal)s), interval + 1 month)
		group by peca.NU_DPL desc
	) filtro
		left join
		(
			select 
			resultado.DS_SCP,
			resultado.DS_CLP,
			resultado.NU_DPL,
			resultado.PERDA_CHAPA,
			resultado.ALTURA_CH,
			resultado.LARGURA_CH
			from(
				select 
					subclasse.DS_SCP,
					classe.DS_CLP,
					apont.NU_OF,
					apont.NU_PECA,
					apont.SEQ_PECA,
					apont.dt_ins,
					setorapont.DS_SET,
					(
						select 
							chapa.ALTURA  
							from mgplc01012 peca
								left join mgplc01011 chapa on (chapa.NU_DPL = peca.NU_DPL)
								left join mgras01010 perda on (peca.NU_DPL = perda.DESTINO_DPL)
								left join mgplc01010 plano on (plano.NU_PLC = chapa.NU_PLC)
							where chapa.CORTADO = "S" and perda.ORIGEM_PER is null
								and peca.NU_PECA = apont.NU_PECA and peca.SEQ_PECA = apont.SEQ_PECA 
								and peca.ID_RETALHO = 'N'
							order by peca.NU_DPL desc
							limit 1
					) as "ALTURA_CH",
					(
						select 
							chapa.LARGURA  
							from mgplc01012 peca
								left join mgplc01011 chapa on (chapa.NU_DPL = peca.NU_DPL)
								left join mgras01010 perda on (peca.NU_DPL = perda.DESTINO_DPL)
								left join mgplc01010 plano on (plano.NU_PLC = chapa.NU_PLC)
							where chapa.CORTADO = "S" and perda.ORIGEM_PER is null
								and peca.NU_PECA = apont.NU_PECA and peca.SEQ_PECA = apont.SEQ_PECA 
								and peca.ID_RETALHO = 'N'
							order by peca.NU_DPL desc
							limit 1
					) as "LARGURA_CH",
					(
						select 
							chapa.NU_DPL 
							from mgplc01012 peca
								left join mgplc01011 chapa on (chapa.NU_DPL = peca.NU_DPL)
								left join mgras01010 perda on (peca.NU_DPL = perda.DESTINO_DPL)
								left join mgplc01010 plano on (plano.NU_PLC = chapa.NU_PLC)
							where chapa.CORTADO = "S" and perda.ORIGEM_PER is null
								and peca.NU_PECA = apont.NU_PECA and peca.SEQ_PECA = apont.SEQ_PECA 
								and peca.ID_RETALHO = 'N'
							order by peca.NU_DPL desc
							limit 1
					) as "NU_DPL",
					(
						select 
							case 
								when perda.ORIGEM_PER is null
								then IFNULL((((chapa.ALTURA/1000)*(chapa.LARGURA/1000)))-(select 
										SUM((m2.QT_LARGURA/1000)*(m2.QT_ALTURA/1000)) 
											from mgplc01012 p
												left join mgorf01011 m2 on (m2.NU_PECA = p.NU_PECA)
											where p.ID_RETALHO = 'N' 
												and p.NU_DPL = peca.NU_DPL),0) 
								else IFNULL(-(select 
										SUM((m2.QT_LARGURA/1000)*(m2.QT_ALTURA/1000)) 
											from mgplc01012 p 
												left join mgorf01011 m2 on (m2.NU_PECA = p.NU_PECA)
											where p.ID_RETALHO = 'N' 
												and p.NU_DPL = peca.NU_DPL),0)
								end as "M2"
							from mgplc01012 peca
								left join mgplc01011 chapa on (chapa.NU_DPL = peca.NU_DPL)
								left join mgras01010 perda on (peca.NU_DPL = perda.DESTINO_DPL)
								left join mgplc01010 plano on (plano.NU_PLC = chapa.NU_PLC)
							where chapa.CORTADO = "S" and perda.ORIGEM_PER is null
								and peca.NU_PECA = apont.NU_PECA and peca.SEQ_PECA = apont.SEQ_PECA 
								and peca.ID_RETALHO = 'N'
							order by peca.NU_DPL desc
							limit 1
					) as "PERDA_CHAPA"
					from mgwkf01010 apont
						left join mgset01010 setorapont on (setorapont.NU_SET = apont.NU_SET)
						left join mgorf01011 m2 on (m2.NU_PECA = apont.NU_PECA)
						left join mgpro01010 produto on (produto.NU_PRO = m2.NU_PRO)
						left join mgclp01010 classe on (classe.NU_CLP = produto.NU_CLP)
						left join mgscp01010 subclasse on (subclasse.NU_SCP = produto.NU_SCP)
					where apont.dt_ins between date(%(DataInicial)s) and date(%(DataFinal)s)
						and (setorapont.DS_SET = 'CORTE DE CHAPA' or setorapont.DS_SET = 'CORTE ESPECIAL')
						-- and classe.DS_CLP = 'VERDE' and subclasse.DS_SCP = '10MM'
					order by subclasse.DS_SCP asc, classe.DS_CLP asc, apont.NU_PECA asc, apont.SEQ_PECA asc
				) resultado
				group by resultado.NU_DPL
		) PERDA on PERDA.NU_DPL = filtro.NU_DPL
	where PERDA.DS_SCP is not null
	order by filtro.NU_DPL asc
	) X 
	group by MIX, Chapa, Classe, Subclasse