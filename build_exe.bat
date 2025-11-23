@echo off
echo 🏷️ CRIANDO EXECUTAVEL DO GERADOR DE ETIQUETAS...
echo.

REM Ativa o ambiente virtual se existir
if exist ".venv\Scripts\activate.bat" (
    echo ✅ Ativando ambiente virtual...
    call .venv\Scripts\activate.bat
)

echo 📦 Criando executável com PyInstaller...
pyinstaller --onefile --windowed --name="Gerador_Etiquetas" --distpath="dist" --workpath="build" --specpath="." app.py

echo.
echo ✅ EXECUTÁVEL CRIADO COM SUCESSO!
echo 📂 Local: dist\Gerador_Etiquetas.exe
echo.
echo 💡 Para distribuir o aplicativo:
echo    1. Copie o arquivo "dist\Gerador_Etiquetas.exe"
echo    2. Envie para qualquer computador Windows
echo    3. Execute diretamente (não precisa instalar Python)
echo.
pause
