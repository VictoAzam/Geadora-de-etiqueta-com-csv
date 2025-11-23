@echo off
:: ===============================================
:: 🏷️ SCRIPT DE COMPILAÇÃO - INSTALADOR WIZARD
:: ===============================================
:: 
:: Script para compilar o instalador wizard NSIS
:: do Gerador de Etiquetas Profissional
::
:: Desenvolvedor: Victor Hugo Azambuja
:: Data: 2025
::
:: ===============================================

echo.
echo ===============================================
echo     GERADOR DE ETIQUETAS - BUILD WIZARD V2
echo              INSTALAÇÃO INTELIGENTE
echo ===============================================
echo.
echo NOVA ESTRATÉGIA:
echo + Usuario instala Python separadamente (mais confiável)
echo + Instalador só cuida das dependências (mais rápido)
echo + Processo simplificado sem problemas de conexão
echo.

::  Verifica se NSIS está instalado
set NSIS_PATH="C:\Program Files (x86)\NSIS\makensis.exe"
if exist %NSIS_PATH% (
    echo [INFO] NSIS encontrado em: %NSIS_PATH%
) else (
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
        pause
        exit /b 1
    ) else (
        set NSIS_PATH=makensis
    )
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
    echo [AVISO] Arquivo LICENSE.txt não encontrado, criando um padrão...
    call :CreateLicense
)

:: Verifica se installer_wizard.nsi existe
if not exist "installer_wizard.nsi" (
    echo [ERRO] Arquivo 'installer_wizard.nsi' não encontrado!
    echo.
    pause
    exit /b 1
)

echo [OK] Todos os arquivos necessários encontrados.
echo.

echo [INFO] Compilando instalador wizard...
echo.

:: Compila o instalador
%NSIS_PATH% /V2 installer_wizard.nsi

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===============================================
    echo           COMPILAÇÃO CONCLUÍDA!
    echo ===============================================
    echo.
    echo O instalador wizard foi criado com sucesso:
    echo   Instalador_Gerador_Etiquetas_Wizard_v1.0.exe
    echo.
    echo NOVA ABORDAGEM - Recursos do instalador:
    echo   ✓ Verifica se Python está instalado
    echo   ✓ Instala apenas pandas e reportlab via pip
    echo   ✓ Processo rápido e confiável (sem download)
    echo   ✓ Tamanho pequeno (~5MB vs 70+MB)
    echo   ✓ Funciona sem conexão com internet
    echo.
    echo INSTRUÇÕES PARA O USUÁRIO:
    echo   1. Instalar Python primeiro (python.org)
    echo   2. Marcar 'Add Python to PATH' na instalação
    echo   3. Executar este instalador
    echo.
    echo Veja o arquivo GUIA_INSTALACAO_INTELIGENTE.md para detalhes!
    echo.
) else (
    echo.
    echo [ERRO] Falha na compilação do instalador!
    echo Verifique os erros acima e corrija o script NSIS.
    echo.
)

pause
exit /b %ERRORLEVEL%

:: ===============================================
:: FUNÇÃO PARA CRIAR LICENSE PADRÃO
:: ===============================================
:CreateLicense
echo MIT License > LICENSE.txt
echo. >> LICENSE.txt
echo Copyright (c) 2025 Victor Hugo Ribeiro dos Santos Azambuja Primo >> LICENSE.txt
echo. >> LICENSE.txt
echo Permission is hereby granted, free of charge, to any person obtaining a copy >> LICENSE.txt
echo of this software and associated documentation files (the "Software"^), to deal >> LICENSE.txt
echo in the Software without restriction, including without limitation the rights >> LICENSE.txt
echo to use, copy, modify, merge, publish, distribute, sublicense, and/or sell >> LICENSE.txt
echo copies of the Software, and to permit persons to whom the Software is >> LICENSE.txt
echo furnished to do so, subject to the following conditions: >> LICENSE.txt
echo. >> LICENSE.txt
echo The above copyright notice and this permission notice shall be included in all >> LICENSE.txt
echo copies or substantial portions of the Software. >> LICENSE.txt
echo. >> LICENSE.txt
echo THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR >> LICENSE.txt
echo IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, >> LICENSE.txt
echo FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE >> LICENSE.txt
echo AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER >> LICENSE.txt
echo LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, >> LICENSE.txt
echo OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE >> LICENSE.txt
echo SOFTWARE. >> LICENSE.txt
echo [OK] LICENSE.txt criado com licença MIT padrão.
goto :eof
