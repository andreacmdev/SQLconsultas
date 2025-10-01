SELECT 
    p.NU_PVE AS pedido,
    p.NU_CLI AS cod_cliente,
    cliente.DS_CLI as nome_cliente,
    p.DT_PVE AS data_pedido,
    p.DT_PREVENT as data_previsao,
    p.VLR_FINAL,
    CASE p.ID_STATUS
        WHEN 0 THEN 'Orçamento'
        WHEN 1 THEN 'Aberto'
        WHEN 2 THEN 'Em separação'
        WHEN 4 THEN 'Finalizado'
        WHEN 6 THEN 'Cancelado'
        WHEN 8 THEN 'Em Produção'
        ELSE 'Outro'
    END AS status_pedido,
    CASE p.ID_TP_PED
        WHEN 1 THEN 'Série'
        WHEN 2 THEN 'Engenharia'
        ELSE 'Outro'
    END AS tipo_pedido,
    p.NU_PVE_EXTERNO AS pedido_cliente_externo,
    -- Cálculo dos dias úteis
    (
        (DATEDIFF(CURDATE(), p.DT_PVE) + 1)   
        - (FLOOR((DATEDIFF(CURDATE(), p.DT_PVE) + (WEEKDAY(p.DT_PVE) + 1)) / 7) * 2)  
        - (CASE WHEN WEEKDAY(CURDATE()) = 6 THEN 1 ELSE 0 END)  -- Ajuste se hoje for domingo
    ) AS Dias   
FROM mgpve01010 p
left join mgcli01010 cliente on cliente.NU_CLI = p.NU_CLI 
WHERE p.ID_TP_PED = 2      -- apenas engenharia
 AND p.ID_STATUS IN (2, 8)
  AND (
        (DATEDIFF(CURDATE(), p.DT_PVE) + 1)   
        - (FLOOR((DATEDIFF(CURDATE(), p.DT_PVE) + (WEEKDAY(p.DT_PVE) + 1)) / 7) * 2)  
        - (CASE WHEN WEEKDAY(CURDATE()) = 6 THEN 1 ELSE 0 END)  
      ) > 3;