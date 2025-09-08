; ===============================================
; 🏷️ GERADOR DE ETIQUETAS - INSTALADOR SIMPLES
; ===============================================
; 
; Instalador que usa o Python já instalado no sistema
; SEM download de internet
;
; Desenvolvedor: Victor Hugo Ribeiro dos Santos Azambuja Primo
; GitHub: VictoAzam
; Data: 2025
;
; ===============================================

!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "LogicLib.nsh"

; ===============================================
; CONFIGURAÇÕES GERAIS
; ===============================================

!define PRODUCT_NAME "Gerador de Etiquetas Profissional"
!define PRODUCT_VERSION "1.0"
!define PRODUCT_PUBLISHER "Victor Hugo Azambuja"
!define PRODUCT_WEB_SITE "https://github.com/VictoAzam"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\Gerador_Etiquetas.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION} - Simples"
OutFile "Instalador_Gerador_Etiquetas_Simples_v${PRODUCT_VERSION}.exe"
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show
RequestExecutionLevel admin

; ===============================================
; INTERFACE MODERNA
; ===============================================

!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Página de boas-vindas personalizada
!define MUI_WELCOMEPAGE_TITLE "Bem-vindo ao ${PRODUCT_NAME}!"
!define MUI_WELCOMEPAGE_TEXT "Este assistente irá instalar o ${PRODUCT_NAME} em seu computador.$\r$\n$\r$\n🚀 VERSÃO SIMPLES - Usa o Python já instalado no sistema$\r$\n$\r$\n⚠️ REQUISITO: Python 3.8+ deve estar instalado$\r$\n$\r$\nClique em Avançar para continuar."

; Página de finalização
!define MUI_FINISHPAGE_TITLE "Instalação Concluída!"
!define MUI_FINISHPAGE_TEXT "O ${PRODUCT_NAME} foi instalado com sucesso!$\r$\n$\r$\n📝 PRÓXIMOS PASSOS:$\r$\n1. Certifique-se que Python está instalado$\r$\n2. Execute: pip install pandas reportlab$\r$\n3. Use o aplicativo normalmente$\r$\n$\r$\nClique em Concluir para fechar este assistente."
!define MUI_FINISHPAGE_RUN "$INSTDIR\Gerador_Etiquetas.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Executar o ${PRODUCT_NAME}"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Mostrar informações importantes"

; ===============================================
; PÁGINAS DO INSTALADOR
; ===============================================

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Páginas do desinstalador
!insertmacro MUI_UNPAGE_INSTFILES

; ===============================================
; IDIOMAS
; ===============================================

!insertmacro MUI_LANGUAGE "PortugueseBR"

; ===============================================
; VARIÁVEIS GLOBAIS
; ===============================================

Var PythonFound

; ===============================================
; FUNÇÕES AUXILIARES
; ===============================================

Function .onInit
    ; Verifica se já está instalado
    ReadRegStr $R0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString"
    StrCmp $R0 "" check_python
    
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
    "${PRODUCT_NAME} já está instalado. $\n$\nClique em 'OK' para remover a versão anterior ou 'Cancelar' para cancelar esta instalação." \
    IDOK uninst
    Abort
    
    uninst:
        ClearErrors
        ExecWait '$R0 _?=$INSTDIR'
        
        IfErrors no_remove_uninstaller check_python
        no_remove_uninstaller:
    
    check_python:
        ; Verifica se Python está disponível
        nsExec::ExecToStack 'python --version'
        Pop $0
        Pop $1
        
        ${If} $0 == 0
            StrCpy $PythonFound "Sim"
            DetailPrint "Python encontrado: $1"
        ${Else}
            StrCpy $PythonFound "Não"
            MessageBox MB_YESNO|MB_ICONQUESTION \
            "Python não foi encontrado no sistema.$\r$\n$\r$\nO aplicativo precisa do Python 3.8+ para funcionar.$\r$\n$\r$\nDeseja continuar mesmo assim?$\r$\n(Você pode instalar Python depois)" \
            IDYES continue
            Abort
            continue:
        ${EndIf}
FunctionEnd

Function CheckAndInstallDeps
    ${If} $PythonFound == "Sim"
        DetailPrint "Verificando dependências Python..."
        
        ; Verifica pandas
        nsExec::ExecToStack 'python -c "import pandas"'
        Pop $0
        ${If} $0 != 0
            DetailPrint "Instalando pandas..."
            nsExec::ExecToStack 'python -m pip install pandas'
            Pop $0
            ${If} $0 == 0
                DetailPrint "pandas instalado com sucesso"
            ${Else}
                DetailPrint "Aviso: Falha ao instalar pandas automaticamente"
            ${EndIf}
        ${Else}
            DetailPrint "pandas já está instalado"
        ${EndIf}
        
        ; Verifica reportlab
        nsExec::ExecToStack 'python -c "import reportlab"'
        Pop $0
        ${If} $0 != 0
            DetailPrint "Instalando reportlab..."
            nsExec::ExecToStack 'python -m pip install reportlab'
            Pop $0
            ${If} $0 == 0
                DetailPrint "reportlab instalado com sucesso"
            ${Else}
                DetailPrint "Aviso: Falha ao instalar reportlab automaticamente"
            ${EndIf}
        ${Else}
            DetailPrint "reportlab já está instalado"
        ${EndIf}
    ${Else}
        DetailPrint "Python não encontrado - pulando instalação de dependências"
    ${EndIf}
FunctionEnd

; ===============================================
; SEÇÕES DE INSTALAÇÃO
; ===============================================

Section "Aplicativo Principal" SecMain
    SectionIn RO
    
    SetOutPath "$INSTDIR"
    SetOverwrite ifnewer
    
    ; Copia arquivos principais
    DetailPrint "Instalando aplicativo..."
    File "dist\Gerador_Etiquetas.exe"
    File "README_DISTRIBUICAO.md"
    File "LICENSE.txt"
    
    ; Renomeia README para .txt
    Rename "$INSTDIR\README_DISTRIBUICAO.md" "$INSTDIR\README.txt"
    
    ; Cria diretório de padrões
    CreateDirectory "$INSTDIR\padroes"
    
    ; Cria arquivo de instruções se Python não foi encontrado
    ${If} $PythonFound == "Não"
        DetailPrint "Criando instruções de instalação..."
        FileOpen $0 "$INSTDIR\INSTALAR_PYTHON.txt" w
        FileWrite $0 "INSTRUÇÕES PARA INSTALAR PYTHON$\r$\n"
        FileWrite $0 "================================$\r$\n$\r$\n"
        FileWrite $0 "O Gerador de Etiquetas precisa do Python para funcionar.$\r$\n$\r$\n"
        FileWrite $0 "PASSO 1: Instalar Python$\r$\n"
        FileWrite $0 "-------------------------$\r$\n"
        FileWrite $0 "1. Acesse: https://python.org/downloads$\r$\n"
        FileWrite $0 "2. Baixe Python 3.11 ou superior$\r$\n"
        FileWrite $0 "3. Durante a instalação, marque 'Add Python to PATH'$\r$\n$\r$\n"
        FileWrite $0 "PASSO 2: Instalar Dependências$\r$\n"
        FileWrite $0 "-------------------------------$\r$\n"
        FileWrite $0 "1. Abra o Prompt de Comando$\r$\n"
        FileWrite $0 "2. Execute: pip install pandas reportlab$\r$\n$\r$\n"
        FileWrite $0 "PASSO 3: Usar o Aplicativo$\r$\n"
        FileWrite $0 "---------------------------$\r$\n"
        FileWrite $0 "1. Execute o atalho do Gerador de Etiquetas$\r$\n"
        FileWrite $0 "2. Se der erro, repita os passos acima$\r$\n$\r$\n"
        FileWrite $0 "DICA: Use o arquivo 'run.bat' que verifica tudo automaticamente!"
        FileClose $0
    ${EndIf}
    
    ; Cria script auxiliar de execução
    DetailPrint "Criando script auxiliar..."
    FileOpen $0 "$INSTDIR\run.bat" w
    FileWrite $0 "@echo off$\r$\n"
    FileWrite $0 "echo Verificando Python...$\r$\n"
    FileWrite $0 "python --version >nul 2>&1$\r$\n"
    FileWrite $0 "if %ERRORLEVEL% NEQ 0 ($\r$\n"
    FileWrite $0 "    echo ERRO: Python não encontrado!$\r$\n"
    FileWrite $0 "    echo Leia o arquivo INSTALAR_PYTHON.txt$\r$\n"
    FileWrite $0 "    pause$\r$\n"
    FileWrite $0 "    exit /b 1$\r$\n"
    FileWrite $0 ")$\r$\n"
    FileWrite $0 "echo Verificando dependências...$\r$\n"
    FileWrite $0 "python -c $\"import pandas, reportlab$\" >nul 2>&1$\r$\n"
    FileWrite $0 "if %ERRORLEVEL% NEQ 0 ($\r$\n"
    FileWrite $0 "    echo Instalando dependências...$\r$\n"
    FileWrite $0 "    python -m pip install pandas reportlab$\r$\n"
    FileWrite $0 ")$\r$\n"
    FileWrite $0 "echo Executando aplicativo...$\r$\n"
    FileWrite $0 "$\"$INSTDIR\Gerador_Etiquetas.exe$\"$\r$\n"
    FileClose $0
    
    ; Tenta instalar dependências se Python estiver disponível
    Call CheckAndInstallDeps
    
    ; Registra aplicação
    WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\Gerador_Etiquetas.exe"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\Gerador_Etiquetas.exe"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
    
    ; Cria desinstalador
    WriteUninstaller "$INSTDIR\uninst.exe"
SectionEnd

Section "Atalhos" SecShortcuts
    ; Atalho no Desktop (usa o script run.bat para verificações)
    CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\run.bat" "" "$INSTDIR\Gerador_Etiquetas.exe" 0
    
    ; Atalho no Menu Iniciar
    CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\run.bat" "" "$INSTDIR\Gerador_Etiquetas.exe" 0
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME} (Direto).lnk" "$INSTDIR\Gerador_Etiquetas.exe" "" "$INSTDIR\Gerador_Etiquetas.exe" 0
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Instruções Python.lnk" "$INSTDIR\INSTALAR_PYTHON.txt" "" "" 0
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Desinstalar.lnk" "$INSTDIR\uninst.exe" "" "$INSTDIR\uninst.exe" 0
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Leia-me.lnk" "$INSTDIR\README.txt" "" "" 0
SectionEnd

; ===============================================
; DESCRIÇÕES DAS SEÇÕES
; ===============================================

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} "Arquivos principais do aplicativo e scripts auxiliares (obrigatório)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} "Cria atalhos inteligentes no Desktop e Menu Iniciar"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; ===============================================
; DESINSTALADOR
; ===============================================

Section Uninstall
    ; Remove arquivos
    Delete "$INSTDIR\Gerador_Etiquetas.exe"
    Delete "$INSTDIR\README.txt"
    Delete "$INSTDIR\LICENSE.txt"
    Delete "$INSTDIR\INSTALAR_PYTHON.txt"
    Delete "$INSTDIR\run.bat"
    Delete "$INSTDIR\uninst.exe"
    
    ; Remove diretórios
    RMDir /r "$INSTDIR\padroes"
    RMDir "$INSTDIR"
    
    ; Remove atalhos
    Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
    RMDir /r "$SMPROGRAMS\${PRODUCT_NAME}"
    
    ; Remove entradas do registro
    DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
    DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
    
    SetAutoClose true
SectionEnd
