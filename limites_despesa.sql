SELECT
    %(Tipo_Unidade)s as Tipo_Unidade,
    %(Unidade)s as Unidade,
    limites.IdLimiteDespesa AS Codigo,
    classificacao.DS_TPD AS classificacao,
    centro_custo.DS_CCU AS centro_custo,
    plano.DS_CPC AS plano_conta,
    limites.LIMITE AS limite,
    limites.ID_ATIVO AS Ativo,
    DATE(limites.DT_INS) AS data_criacao, -- Apenas a data
    DATE(limites.DT_ALT) AS data_alteracao -- Apenas a data
FROM 
    limitesdespesas limites
LEFT JOIN 
    mgtpd01010 classificacao ON limites.NU_TPD = classificacao.NU_TPD 
LEFT JOIN 
    mgccu01010 centro_custo ON limites.NU_CCU = centro_custo.NU_CCU 
LEFT JOIN 
    mgcpc01010 plano ON limites.NU_CPC = plano.NU_CPC;