; ===============================================
; 🏷️ GERADOR DE ETIQUETAS - INSTALADOR WIZARD
; ===============================================
; 
; Instalador profissional com download automático
; de Python e dependências se necessário.
;
; Desenvolvedor: Victor Hugo Ribeiro dos Santos Azambuja Primo
; GitHub: VictoAzam
; Data: 2025
;
; ===============================================

!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "WinVer.nsh"
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

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "Instalador_Gerador_Etiquetas_Wizard_v${PRODUCT_VERSION}.exe"
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
!define MUI_WELCOMEPAGE_TEXT "Este assistente irá guiá-lo através da instalação do ${PRODUCT_NAME}.$\r$\n$\r$\nEste aplicativo permite gerar etiquetas profissionais em PDF a partir de arquivos CSV/TXT/TSV.$\r$\n$\r$\nClique em Avançar para continuar."

; Página de licença
!define MUI_LICENSEPAGE_TEXT_TOP "Por favor, leia os termos de uso antes de continuar com a instalação."
!define MUI_LICENSEPAGE_TEXT_BOTTOM "Se você aceitar os termos do acordo, clique em 'Aceito' para continuar. Você deve aceitar o acordo para instalar o ${PRODUCT_NAME}."

; Página de componentes personalizada
!define MUI_COMPONENTSPAGE_TEXT_TOP "Selecione os componentes que você deseja instalar e desmarque os componentes que você não deseja instalar. Clique em Avançar para continuar."

; Página de instalação
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "Instalação Concluída"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "A instalação foi concluída com sucesso."

; Página de finalização
!define MUI_FINISHPAGE_TITLE "Instalação do ${PRODUCT_NAME} Concluída"
!define MUI_FINISHPAGE_TEXT "O ${PRODUCT_NAME} foi instalado com sucesso em seu computador.$\r$\n$\r$\nClique em Concluir para fechar este assistente."
!define MUI_FINISHPAGE_RUN "$INSTDIR\Gerador_Etiquetas.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Executar o ${PRODUCT_NAME}"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Mostrar informações importantes"

; ===============================================
; PÁGINAS DO INSTALADOR
; ===============================================

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
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

Var PythonInstalled
Var PythonPath
Var TempDir

; ===============================================
; FUNÇÕES AUXILIARES
; ===============================================

Function .onInit
    ; Verifica se já está instalado
    ReadRegStr $R0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString"
    StrCmp $R0 "" done
    
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
    "${PRODUCT_NAME} já está instalado. $\n$\nClique em 'OK' para remover a versão anterior ou 'Cancelar' para cancelar esta instalação." \
    IDOK uninst
    Abort
    
    uninst:
        ClearErrors
        ExecWait '$R0 _?=$INSTDIR'
        
        IfErrors no_remove_uninstaller done
        no_remove_uninstaller:
    
    done:
FunctionEnd

Function CheckPython
    ; Verifica se Python está instalado
    DetailPrint "Verificando instalação do Python..."
    
    ; Tenta Python 3.8+
    nsExec::ExecToStack 'python --version'
    Pop $0
    Pop $1
    
    ${If} $0 == 0
        DetailPrint "Python encontrado: $1"
        StrCpy $PythonInstalled "1"
        StrCpy $PythonPath "python"
    ${Else}
        ; Tenta py launcher
        nsExec::ExecToStack 'py --version'
        Pop $0
        Pop $1
        
        ${If} $0 == 0
            DetailPrint "Python encontrado via py launcher: $1"
            StrCpy $PythonInstalled "1"
            StrCpy $PythonPath "py"
        ${Else}
            DetailPrint "Python não encontrado no sistema"
            StrCpy $PythonInstalled "0"
        ${EndIf}
    ${EndIf}
FunctionEnd

Function DownloadPython
    DetailPrint "Baixando Python 3.11.7..."
    
    ; Cria diretório temporário
    GetTempFileName $TempDir
    Delete $TempDir
    CreateDirectory $TempDir
    
    ; URL do Python 3.11.7 (64-bit)
    StrCpy $1 "$TempDir\python-installer.exe"
    NSISdl::download "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe" $1
    
    Pop $0
    ${If} $0 == "success"
        DetailPrint "Download do Python concluído com sucesso"
    ${Else}
        DetailPrint "Erro no download do Python: $0"
        MessageBox MB_OK|MB_ICONSTOP "Erro ao baixar o Python. Verifique sua conexão com a internet e tente novamente."
        Abort
    ${EndIf}
FunctionEnd

Function InstallPython
    DetailPrint "Instalando Python..."
    
    ; Instala Python silenciosamente
    ExecWait '"$TempDir\python-installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0' $0
    
    ${If} $0 == 0
        DetailPrint "Python instalado com sucesso"
        StrCpy $PythonInstalled "1"
        StrCpy $PythonPath "python"
    ${Else}
        DetailPrint "Erro na instalação do Python (código: $0)"
        MessageBox MB_OK|MB_ICONSTOP "Erro na instalação do Python. Tente instalar manualmente."
        Abort
    ${EndIf}
    
    ; Limpa arquivos temporários
    Delete "$TempDir\python-installer.exe"
    RMDir $TempDir
FunctionEnd

Function InstallDependencies
    DetailPrint "Instalando dependências Python..."
    
    ; Instala pandas
    DetailPrint "Instalando pandas..."
    nsExec::ExecToStack '$PythonPath -m pip install pandas'
    Pop $0
    Pop $1
    
    ${If} $0 == 0
        DetailPrint "pandas instalado com sucesso"
    ${Else}
        DetailPrint "Aviso: Erro ao instalar pandas"
    ${EndIf}
    
    ; Instala reportlab
    DetailPrint "Instalando reportlab..."
    nsExec::ExecToStack '$PythonPath -m pip install reportlab'
    Pop $0
    Pop $1
    
    ${If} $0 == 0
        DetailPrint "reportlab instalado com sucesso"
    ${Else}
        DetailPrint "Aviso: Erro ao instalar reportlab"
    ${EndIf}
FunctionEnd

; ===============================================
; SEÇÕES DE INSTALAÇÃO
; ===============================================

Section "Arquivos Principais" SecMain
    SectionIn RO
    
    SetOutPath "$INSTDIR"
    SetOverwrite ifnewer
    
    ; Copia arquivos principais
    File "dist\Gerador_Etiquetas.exe"
    File "README_DISTRIBUICAO.md"
    File "LICENSE.txt"
    
    ; Renomeia README para .txt
    Rename "$INSTDIR\README_DISTRIBUICAO.md" "$INSTDIR\README.txt"
    
    ; Cria diretório de padrões
    CreateDirectory "$INSTDIR\padroes"
    
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

Section "Python e Dependências" SecPython
    ; Verifica Python
    Call CheckPython
    
    ${If} $PythonInstalled == "0"
        DetailPrint "Python não encontrado. Iniciando download..."
        Call DownloadPython
        Call InstallPython
    ${Else}
        DetailPrint "Python já está instalado"
    ${EndIf}
    
    ; Instala dependências sempre (garante versões atualizadas)
    Call InstallDependencies
SectionEnd

Section "Atalhos" SecShortcuts
    ; Atalho no Desktop
    CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\Gerador_Etiquetas.exe" "" "$INSTDIR\Gerador_Etiquetas.exe" 0
    
    ; Atalho no Menu Iniciar
    CreateDirectory "$SMPROGRAMS\${PRODUCT_NAME}"
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\Gerador_Etiquetas.exe" "" "$INSTDIR\Gerador_Etiquetas.exe" 0
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Desinstalar.lnk" "$INSTDIR\uninst.exe" "" "$INSTDIR\uninst.exe" 0
    CreateShortCut "$SMPROGRAMS\${PRODUCT_NAME}\Leia-me.lnk" "$INSTDIR\README.txt" "" "" 0
SectionEnd

; ===============================================
; DESCRIÇÕES DAS SEÇÕES
; ===============================================

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} "Arquivos principais do aplicativo (obrigatório)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPython} "Instala Python e dependências necessárias automaticamente"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecShortcuts} "Cria atalhos no Desktop e Menu Iniciar"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; ===============================================
; DESINSTALADOR
; ===============================================

Section Uninstall
    ; Remove arquivos
    Delete "$INSTDIR\Gerador_Etiquetas.exe"
    Delete "$INSTDIR\README.txt"
    Delete "$INSTDIR\LICENSE.txt"
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
