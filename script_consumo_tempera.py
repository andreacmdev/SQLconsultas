## código de box existente nas unidades
import pandas as pd
import psycopg2

dbname = "marcolan_carga"
user = "diego.marcolan"
password = "X1t6b2d2"
host = "alumiacocorporativo.ddns.net"
port = "31800"

conn_string = f"dbname='{dbname}' user='{user}' password='{password}' host='{host}' port='{port}'"

sql_query = """


select unidade,
SUM(
  ABS(
    REPLACE(qtd_movimentacao, ',', '.')::numeric
  )
) AS quantidade,
nome_produto,
categoria,
classe,
subclasse,
cod_produto
from estoque_produtos ep 
where data_movimentacao::DATE >= '2026-01-01' and tipo_unidade = 'Tempera'
AND (
  categoria ILIKE '%CHAPAR%'
  OR categoria ILIKE '%CORT%'
  or categoria ilike '%TEMPER%'
)
AND ep.tipo_movimentacao = 'PRODUCAO'
group by unidade, nome_produto, categoria, classe, subclasse, cod_produto


"""

# Função para executar a consulta SQL e retornar um DataFrame pandas
def execute_sql_query(sql_query, conn_string):
    try:
        # Conectar ao banco de dados
        conn = psycopg2.connect(conn_string)
        
        # Executar a consulta SQL e ler os resultados em um DataFrame
        df = pd.read_sql_query(sql_query, conn)
        
        # Fechar a conexão com o banco de dados
        conn.close()
        
        return df
    except Exception as e:
        print("Erro ao executar a consulta SQL:", e)

# Executar a consulta SQL e obter o DataFrame resultante
df = execute_sql_query(sql_query, conn_string)

# Definir o caminho do arquivo Excel onde os dados serão salvos
file_path = r"C:\Users\andre\OneDrive\Documentos\Development\Alumiaço\Toneladas\consumido_tempera.xlsx"

# Salvar o DataFrame em um arquivo Excel
df.to_excel(file_path, index=False)

print("Planilha gerada com sucesso em:", file_path)