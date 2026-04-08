    select
        %(Tipo_Unidade)s AS Tipo_Unidade,
        %(Unidade)s AS Unidade,   
     DS_FOR
     from mgfor01010 m 
    where m.DS_FOR like '%DRIVE%'