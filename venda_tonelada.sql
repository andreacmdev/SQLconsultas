SELECT 
    eg.tipo_unidade,
    eg.unidade,
    DATE_TRUNC('month', eg.data_hora_entregue)::date AS mes,
    eg.nome_produto,
    eg.categoria_produto,
    eg.classe_produto,
    eg.sub_classe_produto,
    SUM(
        REPLACE(
            REPLACE(eg.qtd_entregue::TEXT, '.', ''), 
        ',', '.')::NUMERIC
    ) AS qtd_total,
      SUM(REPLACE(eg.metragem_entregue::text, ',', '.')::numeric) AS metragem_total,
    SUM(eg.valor_entregue) AS valor_total
FROM entregas_geral eg
LEFT JOIN mapeamento_clientes mc 
    ON eg.unidade = mc.unidade 
   AND eg.cod_cliente = mc.codcliente 
WHERE eg.categoria_produto IN (
    'CHAPARIA COMUM','CHAPARIA CORTADA','CHAPARIA ESPELHO',
    'CHAPARIA FANTASIA','CHAPARIA LAMINADO','CHAPARIA LAMINADO REFLETIVO',
    'CHAPARIA PINTADA','CHAPARIA REFLETIVO','LAMINADO','VIDRO CORTADO',
    'TEMPERADO','TEMPERADO ESPECIAL','BOX PADRÃO','BOX PADRÃO 1800',
    'BOX PADRÃO 1880','BOX PADRÃO 1900','BOX PADRÃO/ JANELA PADRÃO',
    'BOX PADRÃO/ JANELA PADRÃO ROTA','ENG PADRAO','TEMPERADO PADRÃO'
)
AND eg.data_hora_entregue >= '2025-03-01'
AND mc.ramo_atividade != 'INTERCOMPANY'
AND eg.unidade IN (
    'VITORIA DE SANTO ANTAO','4D Vidros','INBRAVIDROS','BRASILIA',
    'Oazem','FORTALEZA','ALLGLASS TEMPERA','TEMPER PATOS',
    'UBERVIDROS','Agreste Vidros','Alumiaco Recife',
    'DVM PARAIBA','GM Maceio','GM Recife', 'ALAGOAS VIDROS'
)
GROUP BY 
    eg.tipo_unidade,
    eg.unidade,
    DATE_TRUNC('month', eg.data_hora_entregue),
    eg.nome_produto,
    eg.categoria_produto,
    eg.classe_produto,
    eg.sub_classe_produto
ORDER BY 
    eg.unidade,
    mes,
    eg.nome_produto;