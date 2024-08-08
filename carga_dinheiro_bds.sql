-- dinheiro bodinhos
SELECT 
    pf.tipo_unidade ,
    pf.unidade ,
    pf.valor_titulo ,
    pf.last_updated
FROM  
  painel_financeiro pf  
  where 
  tipo_unidade = 'Bodinho' and 
  tipo_documento = 'Dinheiro'