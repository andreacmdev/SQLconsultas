SELECT *
FROM (
    SELECT 
        m.NU_MOV AS CodMovimentacao,
        m.NU_PRO AS IdProduto,
        CASE 
            WHEN m.NU_MMV = '501' THEN 'VENDA' 
            WHEN m.NU_MMV = '502' THEN 'COMPRA' 
            WHEN m.NU_MMV = '600' THEN 'PRODUCAO' 
            ELSE 'OUTROS'
        END AS TipoMovimentacao,
        m.OBS_MOV AS Observacao,
        CASE  
            WHEN m.TP_MOV = 1 THEN m.QT_MOV
            WHEN m.TP_MOV = 2 THEN m.QT_MOV * -1
        END AS QtdMovimentacao,
        m.DT_MOV AS DataMovimentacao,
        u.DS_LOGIN,
        m.SALDO_ATUAL AS SaldoDia,
        p.CodProduto,
        p.NomeProduto,
        p.Categoria,
        p.Classe,
        p.Subclasse,
        p.CustoUnitario,
        p.EstoqueMinimo,
        p.EstoqueAtual,
        p.EstoqueMetro,
        p.EstoquePeso,
        p.Fator_conversao,
        p.PrecoVenda
    FROM mgmov01010 m
    LEFT JOIN mgusu01010 u 
           ON m.NU_USU = u.NU_USU
    RIGHT JOIN (
        SELECT  
            produtos.NU_PRO,
            produtos.DS_COD_INTERNO AS CodProduto,
            produtos.DS_PRO AS NomeProduto,
            categoria.DS_CAT AS Categoria,
            classe.DS_CLP AS Classe,
            subclasse.DS_SCP AS Subclasse,
            produtos.NU_CUSTO AS CustoUnitario,
            produtos.NU_ESTOQMI AS EstoqueMinimo,
            produtos.NU_ESTOQAT AS EstoqueAtual,
            produtos.FAT_CONV1 * produtos.NU_ESTOQAT AS EstoqueMetro,
            produtos.FAT_CONV2 * produtos.NU_ESTOQAT AS EstoquePeso,
            produtos.FAT_CONV1 AS Fator_conversao,
            produtos.NU_PRECOV AS PrecoVenda
        FROM mgpro01010 produtos
        LEFT JOIN mgcat01010 categoria 
               ON produtos.NU_CAT = categoria.NU_CAT
        LEFT JOIN mgclp01010 classe 
               ON produtos.NU_CLP = classe.NU_CLP
        LEFT JOIN mgscp01010 subclasse 
               ON produtos.NU_SCP = subclasse.NU_SCP
        WHERE categoria.ID_ATIVO = 'S'
          AND COALESCE(classe.ID_ATIVO, 'S') = 'S'
          AND COALESCE(subclasse.ID_ATIVO, 'S') = 'S'
          AND produtos.ID_ATIVO = 'S'
          AND COALESCE(categoria.ID_USOCONSUMO,'N') != 'S'
          AND produtos.TP_PROD = 1
    ) p
    ON p.NU_PRO = m.NU_PRO
    WHERE m.DT_MOV >= CURDATE() - INTERVAL 100 DAY
      AND LOWER(m.OBS_MOV) LIKE '%kits%'
      AND m.DT_MOV > '2025-01-01'
) z_q
WHERE QtdMovimentacao > 0;