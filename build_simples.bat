@echo off
:: ===============================================
:: 🏷️ SCRIPT DE COMPILAÇÃO - INSTALADOR SIMPLES
:: ===============================================
:: 
:: Script para compilar o instalador simples NSIS
:: que NÃO requer internet
::
:: Desenvolvedor: Victor Hugo Azambuja
:: Data: 2025
::
:: ===============================================

echo.
echo ===============================================
echo    GERADOR DE ETIQUETAS - BUILD SIMPLES
echo ===============================================
echo.
echo 🌟 INSTALADOR SEM INTERNET
echo    - Usa Python já instalado no sistema
echo    - Instala dependências automaticamente
echo    - Funciona offline após Python instalado
echo.

:: Verifica se NSIS está instalado
where makensis >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] NSIS não encontrado no PATH!
    echo.
    echo Por favor:
    echo 1. Baixe o NSIS em: https://nsis.sourceforge.io/Download
    echo 2. Instale o NSIS
    echo 3. Adicione o NSIS ao PATH do sistema
    echo 4. Reinicie o prompt de comando
    echo.
    echo ALTERNATIVA: Use o arquivo .exe já compilado
    echo.
    pause
    exit /b 1
)

echo [INFO] Verificando arquivos necessários...

:: Verifica se o executável existe
if not exist "dist\Gerador_Etiquetas.exe" (
    echo [ERRO] Arquivo 'dist\Gerador_Etiquetas.exe' não encontrado!
    echo.
    echo Execute primeiro:
    echo   build_exe.bat
    echo.
    pause
    exit /b 1
)

:: Verifica se LICENSE.txt existe
if not exist "LICENSE.txt" (
    echo [ERRO] Arquivo LICENSE.txt não encontrado!
    echo.
    pause
    exit /b 1
)

:: Verifica se installer_simples.nsi existe
if not exist "installer_simples.nsi" (
    echo [ERRO] Arquivo 'installer_simples.nsi' não encontrado!
    echo.
    pause
    exit /b 1
)

echo [OK] Todos os arquivos necessários encontrados.
echo.

echo [INFO] Compilando instalador simples...
echo.

:: Compila o instalador
makensis /V2 installer_simples.nsi

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===============================================
    echo           COMPILAÇÃO CONCLUÍDA!
    echo ===============================================
    echo.
    echo O instalador simples foi criado com sucesso:
    echo   Instalador_Gerador_Etiquetas_Simples_v1.0.exe
    echo.
    echo 🌟 CARACTERÍSTICAS DESTE INSTALADOR:
    echo   ✓ NÃO precisa de internet durante instalação
    echo   ✓ Detecta se Python está instalado
    echo   ✓ Instala dependências automaticamente (se Python disponível)
    echo   ✓ Cria scripts auxiliares para verificação
    echo   ✓ Fornece instruções se Python não estiver instalado
    echo   ✓ Atalhos inteligentes
    echo.
    echo 📋 CENÁRIOS DE USO:
    echo   • PC com Python: Instala tudo automaticamente
    echo   • PC sem Python: Fornece instruções claras
    echo   • Problemas de rede: Funciona 100%% offline
    echo.
    echo 🎯 RECOMENDAÇÃO:
    echo   Use este instalador para resolver o problema de conexão!
    echo.
) else (
    echo.
    echo [ERRO] Falha na compilação do instalador!
    echo Verifique os erros acima e corrija o script NSIS.
    echo.
)

pause
exit /b %ERRORLEVEL%
