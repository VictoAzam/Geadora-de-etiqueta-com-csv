@echo off
:: ===============================================
:: 🏷️ SCRIPT DE INICIALIZAÇÃO RÁPIDA
:: ===============================================
:: 
:: Script para configurar o ambiente de desenvolvimento
:: e executar o Gerador de Etiquetas
::
:: Desenvolvedor: Victor Hugo Azambuja
:: Data: 2025
::
:: ===============================================

echo.
echo ===============================================
echo     GERADOR DE ETIQUETAS - INICIALIZAÇÃO
echo ===============================================
echo.

:: Verifica se Python está instalado
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Python não encontrado!
    echo.
    echo Por favor, instale Python 3.8+ em: https://python.org
    echo.
    pause
    exit /b 1
)

echo [OK] Python encontrado

:: Verifica se as dependências estão instaladas
echo [INFO] Verificando dependências...

python -c "import pandas, reportlab" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] Instalando dependências...
    python -m pip install -r requirements.txt
    
    if %ERRORLEVEL% NEQ 0 (
        echo [ERRO] Falha ao instalar dependências!
        pause
        exit /b 1
    )
    
    echo [OK] Dependências instaladas
) else (
    echo [OK] Dependências já estão instaladas
)

:: Cria diretório de padrões se não existir
if not exist "padroes" (
    echo [INFO] Criando diretório de padrões...
    mkdir padroes
)

echo.
echo ===============================================
echo           INICIANDO APLICATIVO
echo ===============================================
echo.
echo 🚀 Executando o Gerador de Etiquetas...
echo.

:: Executa o aplicativo
python app.py

echo.
echo ===============================================
echo              APLICATIVO FECHADO
echo ===============================================
echo.
echo Obrigado por usar o Gerador de Etiquetas! 🏷️
echo.
pause
