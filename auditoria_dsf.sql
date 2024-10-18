select
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   
  	dsf.NU_DSF as numero_dsf,
  	case dsf.ID_STATUS 
  		 when 2 then 'FINALIZADO'
  		 when 3 then 'A CONCILIAR'
  		 when 4 then 'CANCELADO'
  		 when 1 then 'ABERTO'
  		 else 'NAO SEI'
  	end as status_dsf,
  	dsf.DT_DSF as data_dsf,
  	banco.DS_BAN as inst_financeira,
  	conta.DS_CON as conta_credito,
  	case dsf.TP_DSF
  		 when 0 then 'ANTECIPACAO'
  		 when 2 then 'DEPOSITO'
  		 when 1 then 'NAO DETERMINADO 1'
  		 when 3 then 'nao determinado 3'
  		 else 'NAO SEI'
  	end as tipo_dsf	,
  	case dsf.TP_ESPECIE
  		 when 0 then 'CHEQUE'
  		 when 2 then 'DINHEIRO'
  		 when 4 then 'BOLETO'
  		 when 3 then 'CARTAO'
  		 else 'NAO SEI'
  	end as especie,
  	dsf.VALOR_LIQUIDO,
  	dsf.VALOR_BRUTO ,
  	dsf.VALOR_RECOMPRA ,
  	dsf.VALOR_TAXAS ,
  	dsf.DS_OBS ,
  	dsf.DT_REFERENCIA 
from
	mgdsf01010 dsf
left join
	mgban01010 banco on dsf.NU_BAN = banco.NU_BAN
left join
	mgcon01010 conta on dsf.NU_CON = conta.NU_CON 
WHERE
    date(dsf.DT_DSF) BETWEEN CONCAT(YEAR(CURDATE()), '-01-01') AND CURDATE() - INTERVAL 1 DAY
     AND dsf.ID_STATUS IN (1, 3);