import pandas as pd
import os

# Caminho base dos arquivos
base_path = r'C:\Users\andre\OneDrive\Documentos\Development\Alumiaço'

# Caminhos completos
entregas_file = os.path.join(base_path, 'entregues_att.xlsx')
pagamentos_file = os.path.join(base_path, 'pagamentos_lauro_att.xlsx')

# Lendo os relatórios
df_entregas = pd.read_excel(entregas_file)
df_pagamentos = pd.read_excel(pagamentos_file)

# Selecionando apenas as colunas necessárias de pagamentos
df_pagamentos_reduzido = df_pagamentos[['cod_romaneio', 'titulo', 'valor_pago']]

# Relacionando as bases pelo cod_romaneio (left join para manter todas as entregas)
df_relacionado = pd.merge(
    df_entregas,
    df_pagamentos_reduzido,
    how='left',
    on='cod_romaneio'
)

# Reorganizando as colunas: colocar valor_entregue e valor_pago lado a lado
colunas = list(df_entregas.columns) + ['titulo', 'valor_pago']

df_relacionado = df_relacionado[colunas]

# Salvando relatório final
output_file = os.path.join(base_path, 'relatorio_consolidado.xlsx')
df_relacionado.to_excel(output_file, index=False)

print("✅ Relatório consolidado gerado com sucesso!")
print(f"Caminho: {output_file}")
