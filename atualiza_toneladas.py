import subprocess
import sys
from pathlib import Path
from datetime import datetime

# pasta onde estão os scripts
PASTA_SCRIPTS = Path(
    r"C:\Users\andre\OneDrive\Documentos\Development\Alumiaço\Python\RELATÓRIOS\SCRIPTS"
)

# scripts que precisam rodar (ordem importa)
SCRIPTS = [
    "script_base_1.py",
    "script_base_2.py"
]

print(f"[{datetime.now()}] Iniciando rotina Toneladas...")

for script in SCRIPTS:
    script_path = PASTA_SCRIPTS / script

    print(f"[{datetime.now()}] Executando {script}...")

    resultado = subprocess.run(
        [sys.executable, str(script_path)],
        capture_output=True,
        text=True
    )

    if resultado.returncode != 0:
        print(f"❌ Erro no script {script}")
        print(resultado.stderr)
        raise RuntimeError(f"Falha ao executar {script}")

    print(f"✅ {script} finalizado com sucesso")

print(f"[{datetime.now()}] Rotina Toneladas finalizada com sucesso")
