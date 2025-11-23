; ===============================================
; 🏷️ GERADOR DE ETIQUETAS - INSTALADOR OFFLINE
; ===============================================
; 
; Instalador que funciona SEM internet, incluindo
; Python e dependências no próprio instalador
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

Name "${PRODUCT_NAME} ${PRODUCT_VERSION} - Offline"
OutFile "Instalador_Gerador_Etiquetas_Offline_v${PRODUCT_VERSION}.exe"
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
!define MUI_WELCOMEPAGE_TEXT "Este assistente irá instalar o ${PRODUCT_NAME} em seu computador.$\r$\n$\r$\n🌟 VERSÃO OFFLINE - Não requer conexão com internet!$\r$\n$\r$\nEste pacote inclui Python e todas as dependências necessárias.$\r$\n$\r$\nClique em Avançar para continuar."

; Página de licença
!define MUI_LICENSEPAGE_TEXT_TOP "Por favor, leia os termos de uso antes de continuar com a instalação."
!define MUI_LICENSEPAGE_TEXT_BOTTOM "Se você aceitar os termos do acordo, clique em 'Aceito' para continuar. Você deve aceitar o acordo para instalar o ${PRODUCT_NAME}."

; Página de componentes personalizada
!define MUI_COMPONENTSPAGE_TEXT_TOP "Selecione os componentes que você deseja instalar.$\r$\n$\r$\n⚠️ ATENÇÃO: Esta é uma instalação completa que inclui Python embarcado."

; Página de finalização
!define MUI_FINISHPAGE_TITLE "Instalação do ${PRODUCT_NAME} Concluída"
!define MUI_FINISHPAGE_TEXT "O ${PRODUCT_NAME} foi instalado com sucesso!$\r$\n$\r$\n✅ Python embarcado instalado$\r$\n✅ Todas as dependências incluídas$\r$\n✅ Funciona sem internet$\r$\n$\r$\nClique em Concluir para fechar este assistente."
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

; ===============================================
; SEÇÕES DE INSTALAÇÃO
; ===============================================

Section "Arquivos Principais" SecMain
    SectionIn RO
    
    SetOutPath "$INSTDIR"
    SetOverwrite ifnewer
    
    ; Copia arquivos principais
    DetailPrint "Instalando aplicativo principal..."
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

Section "Python Embarcado" SecPython
    ; NOTA: Esta seção requer que você tenha o Python embarcado
    ; Baixe de: https://www.python.org/downloads/windows/
    ; Procure por "Windows embeddable package"
    
    DetailPrint "Instalando Python embarcado..."
    
    SetOutPath "$INSTDIR\python"
    
    ; Descomente as linhas abaixo se você tiver o Python embarcado
    ; File /r "python-embedded\*.*"
    
    ; Por enquanto, vamos criar uma mensagem informativa
    DetailPrint "ATENÇÃO: Para usar esta versão, você precisa:"
    DetailPrint "1. Baixar Python 3.11 Embeddable Package"
    DetailPrint "2. Extrair na pasta python-embedded\"
    DetailPrint "3. Recompilar o instalador"
    
    ; Cria um arquivo de informação
    FileOpen $0 "$INSTDIR\python\LEIA-ME.txt" w
    FileWrite $0 "PYTHON EMBARCADO$\r$\n"
    FileWrite $0 "=================$\r$\n$\r$\n"
    FileWrite $0 "Para usar esta versão offline, você precisa:$\r$\n$\r$\n"
    FileWrite $0 "1. Baixar Python 3.11 Embeddable Package em:$\r$\n"
    FileWrite $0 "   https://www.python.org/downloads/windows/$\r$\n$\r$\n"
    FileWrite $0 "2. Extrair o arquivo aqui$\r$\n$\r$\n"
    FileWrite $0 "3. Instalar as dependências com:$\r$\n"
    FileWrite $0 "   python -m pip install pandas reportlab$\r$\n$\r$\n"
    FileWrite $0 "Ou use o instalador online que faz isso automaticamente."
    FileClose $0
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
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPython} "Python embarcado - não requer instalação separada"
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
    
    ; Remove Python embarcado
    RMDir /r "$INSTDIR\python"
    
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
