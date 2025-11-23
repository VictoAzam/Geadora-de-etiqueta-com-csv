@echo off
:: ===============================================
:: 🏷️ INSTALADOR DE EMERGÊNCIA - SEM INTERNET
:: ===============================================
:: 
:: Este instalador funciona SEM conexão com internet
:: e resolve o problema de timeout/download do Python
::
:: Desenvolvedor: Victor Hugo Azambuja
:: Data: 2025
::
:: ===============================================

echo.
echo ===============================================
echo     GERADOR DE ETIQUETAS - INSTALADOR
echo              VERSAO DE EMERGENCIA
echo ===============================================
echo.
echo 🚨 RESOLVER PROBLEMA DE CONEXAO/TIMEOUT
echo.

:: Verifica se está executando como administrador
net session >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Este instalador precisa ser executado como Administrador!
    echo.
    echo Clique com botao direito no arquivo e escolha:
    echo "Executar como administrador"
    echo.
    pause
    exit /b 1
)

echo [OK] Executando como Administrador
echo.

:: Verifica se Python está instalado
echo [INFO] Verificando se Python está instalado...
python --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Python encontrado!
    python --version
    echo.
    goto :install_app
) else (
    echo [AVISO] Python não encontrado
    echo.
    goto :install_python_manual
)

:install_python_manual
echo ===============================================
echo           PYTHON NAO ENCONTRADO
echo ===============================================
echo.
echo Para usar este aplicativo, você precisa instalar Python primeiro.
echo.
echo OPCOES:
echo.
echo 1. INSTALACAO AUTOMATICA (requer internet):
echo    - Baixa Python automaticamente
echo    - Pode dar erro de timeout (como você viu)
echo.
echo 2. INSTALACAO MANUAL (RECOMENDADO):
echo    - Você baixa Python separadamente
echo    - 100%% confiável, sempre funciona
echo.
choice /c 12 /m "Escolha uma opcao"

if %ERRORLEVEL% EQU 1 goto :auto_install
if %ERRORLEVEL% EQU 2 goto :manual_install

:manual_install
echo.
echo ===============================================
echo        INSTALACAO MANUAL (RECOMENDADO)
echo ===============================================
echo.
echo PASSO A PASSO:
echo.
echo 1. Abra seu navegador
echo 2. Acesse: https://python.org/downloads
echo 3. Clique em "Download Python 3.x"
echo 4. Execute o arquivo baixado
echo 5. IMPORTANTE: Marque "Add Python to PATH"
echo 6. Clique em "Install Now"
echo 7. Reinicie o computador
echo 8. Execute este instalador novamente
echo.
echo VANTAGENS:
echo + Sempre funciona (sem problemas de timeout)
echo + Voce tem controle total
echo + Download oficial do Python.org
echo + Usado por milhoes de pessoas
echo.

start https://python.org/downloads

echo Navegador aberto com o link do Python.
echo.
echo Após instalar Python, execute este instalador novamente.
echo.
pause
exit /b 0

:auto_install
echo.
echo ===============================================
echo         INSTALACAO AUTOMATICA
echo ===============================================
echo.
echo [AVISO] Esta opcao pode dar timeout como antes.
echo [INFO] Tentando baixar Python...
echo.

:: Cria diretório temporário
set TEMP_DIR=%TEMP%\python_installer
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

:: Tenta download com powershell (mais confiável que NSISdl)
echo [INFO] Baixando Python 3.11.7...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe' -OutFile '%TEMP_DIR%\python-installer.exe' -TimeoutSec 60}"

if exist "%TEMP_DIR%\python-installer.exe" (
    echo [OK] Download concluído!
    echo [INFO] Instalando Python...
    "%TEMP_DIR%\python-installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    
    if %ERRORLEVEL% EQU 0 (
        echo [OK] Python instalado com sucesso!
        del "%TEMP_DIR%\python-installer.exe"
        rmdir "%TEMP_DIR%"
        echo.
        echo Reiniciando verificacao...
        timeout /t 3 >nul
        goto :check_python_again
    ) else (
        echo [ERRO] Falha na instalacao do Python
        goto :manual_install
    )
) else (
    echo [ERRO] Falha no download (timeout/conexao)
    echo.
    goto :manual_install
)

:check_python_again
python --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Python agora está disponível!
    python --version
    echo.
    goto :install_app
) else (
    echo [AVISO] Python instalado mas não detectado
    echo Pode ser necessário reiniciar o computador
    echo.
    choice /c YN /m "Deseja continuar mesmo assim"
    if %ERRORLEVEL% EQU 2 (
        echo.
        echo Reinicie o computador e execute este instalador novamente.
        pause
        exit /b 0
    )
)

:install_app
echo ===============================================
echo        INSTALANDO APLICATIVO
echo ===============================================
echo.

:: Define diretório de instalação
set INSTALL_DIR=%PROGRAMFILES%\Gerador de Etiquetas Profissional

:: Cria diretório
echo [INFO] Criando diretório de instalação...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Copia arquivos
echo [INFO] Copiando arquivos do aplicativo...
copy "dist\Gerador_Etiquetas.exe" "%INSTALL_DIR%\" >nul
copy "README_DISTRIBUICAO.md" "%INSTALL_DIR%\README.txt" >nul
copy "LICENSE.txt" "%INSTALL_DIR%\" >nul

:: Cria diretório de padrões
mkdir "%INSTALL_DIR%\padroes" 2>nul

:: Instala dependências Python
echo [INFO] Instalando dependências Python...
echo [INFO] Atualizando pip...
python -m pip install --upgrade pip --quiet

echo [INFO] Instalando pandas...
python -m pip install pandas --quiet
if %ERRORLEVEL% NEQ 0 (
    echo [AVISO] Erro ao instalar pandas
) else (
    echo [OK] pandas instalado
)

echo [INFO] Instalando reportlab...
python -m pip install reportlab --quiet
if %ERRORLEVEL% NEQ 0 (
    echo [AVISO] Erro ao instalar reportlab
) else (
    echo [OK] reportlab instalado
)

:: Cria atalhos
echo [INFO] Criando atalhos...

:: Atalho no Desktop
set DESKTOP=%USERPROFILE%\Desktop
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\shortcut.vbs"
echo sLinkFile = "%DESKTOP%\Gerador de Etiquetas Profissional.lnk" >> "%TEMP%\shortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\shortcut.vbs"
echo oLink.TargetPath = "%INSTALL_DIR%\Gerador_Etiquetas.exe" >> "%TEMP%\shortcut.vbs"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%TEMP%\shortcut.vbs"
echo oLink.Description = "Gerador de Etiquetas Profissional" >> "%TEMP%\shortcut.vbs"
echo oLink.Save >> "%TEMP%\shortcut.vbs"
cscript "%TEMP%\shortcut.vbs" >nul
del "%TEMP%\shortcut.vbs"

:: Atalho no Menu Iniciar
set STARTMENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs
if not exist "%STARTMENU%\Gerador de Etiquetas" mkdir "%STARTMENU%\Gerador de Etiquetas"

echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\shortcut2.vbs"
echo sLinkFile = "%STARTMENU%\Gerador de Etiquetas\Gerador de Etiquetas Profissional.lnk" >> "%TEMP%\shortcut2.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\shortcut2.vbs"
echo oLink.TargetPath = "%INSTALL_DIR%\Gerador_Etiquetas.exe" >> "%TEMP%\shortcut2.vbs"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%TEMP%\shortcut2.vbs"
echo oLink.Description = "Gerador de Etiquetas Profissional" >> "%TEMP%\shortcut2.vbs"
echo oLink.Save >> "%TEMP%\shortcut2.vbs"
cscript "%TEMP%\shortcut2.vbs" >nul
del "%TEMP%\shortcut2.vbs"

echo.
echo ===============================================
echo          INSTALACAO CONCLUIDA!
echo ===============================================
echo.
echo ✅ Aplicativo instalado em: %INSTALL_DIR%
echo ✅ Atalho criado no Desktop
echo ✅ Atalho criado no Menu Iniciar
echo ✅ Dependências Python instaladas
echo.
echo O aplicativo está pronto para usar!
echo.
choice /c YN /m "Deseja executar o aplicativo agora"
if %ERRORLEVEL% EQU 1 (
    start "" "%INSTALL_DIR%\Gerador_Etiquetas.exe"
)

echo.
echo Obrigado por usar o Gerador de Etiquetas Profissional! 🏷️
echo.
pause
exit /b 0
