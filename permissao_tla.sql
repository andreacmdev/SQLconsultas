   select 
    %(Tipo_Unidade)s AS Tipo_Unidade,
    %(Unidade)s AS Unidade, 
    usu.NOM_USU , 
    usu.DS_LOGIN ,
     perfil.DS_PFL , 
     perfil.ID_AUTORIZAR ,
      perm.TP_ACESSO, tla.DS_TLA , tla.NOM_TLA_DLP from mgusu01010 usu
    left join mgpfl01010 perfil on usu.NU_PFL = perfil.NU_PFL 
    left join mgdpf01010 perm on perfil.NU_PFL = perm.NU_PFL 
    left join mgtla01010 tla on perm.NU_TLA = tla.NU_TLA 
    where tla.NU_TLA = '302' and perM.TP_ACESSO = 'A'