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
!define MUI_WELCOMEPAGE_TEXT "Este assistente irá instalar o ${PRODUCT_NAME} em seu computador.$\r$\n$\r$\n📋 PRÉ-REQUISITO: Python 3.8+ deve estar instalado$\r$\n$\r$\nSe você não tem Python instalado:$\r$\n1. Baixe em: https://python.org$\r$\n2. Instale marcando 'Add to PATH'$\r$\n3. Reinicie e execute este instalador novamente$\r$\n$\r$\nEste instalador irá verificar o Python e instalar apenas as dependências necessárias.$\r$\n$\r$\nClique em Avançar para continuar."

; Página de licença
!define MUI_LICENSEPAGE_TEXT_TOP "Por favor, leia os termos de uso antes de continuar com a instalação."
!define MUI_LICENSEPAGE_TEXT_BOTTOM "Se você aceitar os termos do acordo, clique em 'Aceito' para continuar. Você deve aceitar o acordo para instalar o ${PRODUCT_NAME}."

; Página de componentes personalizada
!define MUI_COMPONENTSPAGE_TEXT_TOP "Selecione os componentes que você deseja instalar.$\r$\n$\r$\n✅ ESTRATÉGIA INTELIGENTE:$\r$\n• Python deve ser instalado separadamente pelo usuário$\r$\n• Este instalador só cuida das dependências Python$\r$\n• Processo mais rápido e confiável"

; Página de instalação
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "Instalação Concluída"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "A instalação foi concluída com sucesso."

; Página de finalização
!define MUI_FINISHPAGE_TITLE "Instalação do ${PRODUCT_NAME} Concluída"
!define MUI_FINISHPAGE_TEXT "O ${PRODUCT_NAME} foi instalado com sucesso em seu computador.$\r$\n$\r$\n✅ Aplicativo instalado$\r$\n✅ Dependências Python configuradas$\r$\n✅ Atalhos criados$\r$\n$\r$\nClique em Concluir para fechar este assistente."
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
    ; Verifica se Python está instalado e acessível
    DetailPrint "Verificando instalação do Python..."
    
    ; Tenta Python direto
    nsExec::ExecToStack 'python --version'
    Pop $0
    Pop $1
    
    ${If} $0 == 0
        DetailPrint "✅ Python encontrado: $1"
        StrCpy $PythonInstalled "1"
        StrCpy $PythonPath "python"
        Return
    ${EndIf}
    
    ; Tenta py launcher
    nsExec::ExecToStack 'py --version'
    Pop $0
    Pop $1
    
    ${If} $0 == 0
        DetailPrint "✅ Python encontrado via py launcher: $1"
        StrCpy $PythonInstalled "1"
        StrCpy $PythonPath "py"
        Return
    ${EndIf}
    
    ; Python não encontrado
    DetailPrint "❌ Python não encontrado no sistema"
    StrCpy $PythonInstalled "0"
    
    ; Mostra mensagem de erro com instruções
    MessageBox MB_OK|MB_ICONSTOP "⚠️ PYTHON NÃO ENCONTRADO$\r$\n$\r$\nPara usar este aplicativo, você precisa instalar Python primeiro:$\r$\n$\r$\n1. Acesse: https://python.org/downloads$\r$\n2. Baixe Python 3.8 ou superior$\r$\n3. Durante a instalação, marque 'Add Python to PATH'$\r$\n4. Reinicie o computador$\r$\n5. Execute este instalador novamente$\r$\n$\r$\nA instalação será cancelada agora."
    
    Abort
FunctionEnd

Function InstallDependencies
    DetailPrint "📦 Instalando dependências Python..."
    
    ; Atualiza pip primeiro
    DetailPrint "Atualizando pip..."
    nsExec::ExecToStack '$PythonPath -m pip install --upgrade pip'
    Pop $0
    Pop $1
    
    ; Instala pandas
    DetailPrint "📊 Instalando pandas..."
    nsExec::ExecToStack '$PythonPath -m pip install pandas'
    Pop $0
    Pop $1
    
    ${If} $0 == 0
        DetailPrint "✅ pandas instalado com sucesso"
    ${Else}
        DetailPrint "⚠️ Aviso: Erro ao instalar pandas"
        MessageBox MB_OK|MB_ICONEXCLAMATION "Aviso: Falha ao instalar pandas.$\r$\nVocê pode instalar manualmente depois com:$\r$\npip install pandas"
    ${EndIf}
    
    ; Instala reportlab
    DetailPrint "📄 Instalando reportlab..."
    nsExec::ExecToStack '$PythonPath -m pip install reportlab'
    Pop $0
    Pop $1
    
    ${If} $0 == 0
        DetailPrint "✅ reportlab instalado com sucesso"
    ${Else}
        DetailPrint "⚠️ Aviso: Erro ao instalar reportlab"
        MessageBox MB_OK|MB_ICONEXCLAMATION "Aviso: Falha ao instalar reportlab.$\r$\nVocê pode instalar manualmente depois com:$\r$\npip install reportlab"
    ${EndIf}
    
    DetailPrint "🎉 Instalação de dependências concluída!"
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

Section "Dependências Python" SecPython
    ; Verifica se Python está instalado
    Call CheckPython
    
    ; Como chegamos até aqui, Python está instalado
    DetailPrint "✅ Python encontrado no sistema"
    
    ; Instala apenas as dependências
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
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPython} "Instala pandas e reportlab via pip (requer Python pré-instalado)"
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
