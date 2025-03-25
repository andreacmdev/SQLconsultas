select 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade,   
    m.NU_CON ,
    m.DS_CON ,
    m.DT_INS ,
    m.ID_ATIVO 
from mgcon01010 m
