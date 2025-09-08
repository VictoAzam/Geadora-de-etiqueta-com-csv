; Script NSIS para Gerador de Etiquetas
; Criado por Victor Hugo Ribeiro dos Santos Azambuja Primo (VictoAzam)

!define APPNAME "Gerador de Etiquetas Profissional"
!define COMPANYNAME "VictoAzam"
!define DESCRIPTION "Aplicativo para gerar etiquetas em PDF a partir de arquivos CSV/TXT/TSV"
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD 0
!define HELPURL "https://github.com/VictoAzam"
!define UPDATEURL "https://github.com/VictoAzam"
!define ABOUTURL "https://github.com/VictoAzam"
!define INSTALLSIZE 50000

; Configurações do instalador
Name "${APPNAME}"
Icon "icon.ico"
OutFile "Instalador_Gerador_Etiquetas_v1.0.exe"
InstallDir "$PROGRAMFILES\${APPNAME}"
InstallDirRegKey HKCU "Software\${APPNAME}" ""
RequestExecutionLevel admin

; Páginas do instalador
Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Section "Principal"
    SetOutPath $INSTDIR
    
    ; Arquivos do aplicativo
    File "dist\Gerador_Etiquetas.exe"
    
    ; Criar atalho no desktop
    CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\Gerador_Etiquetas.exe" "" "$INSTDIR\Gerador_Etiquetas.exe" 0
    
    ; Criar atalho no menu iniciar
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\Gerador_Etiquetas.exe" "" "$INSTDIR\Gerador_Etiquetas.exe" 0
    CreateShortCut "$SMPROGRAMS\${APPNAME}\Desinstalar.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
    
    ; Registrar no sistema
    WriteRegStr HKCU "Software\${APPNAME}" "" $INSTDIR
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$\"$INSTDIR$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANYNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "HelpLink" "${HELPURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "URLUpdateInfo" "${UPDATEURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "URLInfoAbout" "${ABOUTURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "EstimatedSize" ${INSTALLSIZE}
    
    ; Criar desinstalador
    WriteUninstaller "$INSTDIR\uninstall.exe"
    
    MessageBox MB_OK "Instalação concluída com sucesso!$\n$\nO ${APPNAME} foi instalado em:$\n$INSTDIR$\n$\nVocê pode encontrar o atalho no Desktop e no Menu Iniciar."
SectionEnd

Section "Uninstall"
    ; Remover arquivos
    Delete "$INSTDIR\Gerador_Etiquetas.exe"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"
    
    ; Remover atalhos
    Delete "$DESKTOP\${APPNAME}.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\Desinstalar.lnk"
    RMDir "$SMPROGRAMS\${APPNAME}"
    
    ; Remover registros
    DeleteRegKey HKCU "Software\${APPNAME}"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
    
    MessageBox MB_OK "${APPNAME} foi desinstalado com sucesso!"
SectionEnd
