!include "MUI2.nsh"

!define APPNAME "Overwatch"
!define COMPANY "Reak"
!define VERSION "1.0.0"
!define INSTALLDIR "$PROGRAMFILES\${COMPANY}\${APPNAME}"

Var StartOnBoot

Name "${APPNAME}"
OutFile "${APPNAME}-Setup.exe"

Icon "input\app.ico"
UninstallIcon "input\app.ico"

InstallDir "${INSTALLDIR}"
RequestExecutionLevel admin

Page Directory
Page Custom StartOnBootPage
Page InstFiles

Function StartOnBootPage
    !insertmacro MUI_HEADER_TEXT "Startup Option" "Choose whether the app starts with Windows"

    nsDialogs::Create /NOUNLOAD 1018
    Pop $0

    ${If} $0 == error
        Abort
    ${EndIf}

    ${NSD_CreateCheckbox} 10u 10u 200u 12u "Run Overwatch at system startup"
    Pop $1
    ${NSD_Check} $1   ; default = checked

    nsDialogs::Show
FunctionEnd

Function StartOnBootPageLeave
    ${NSD_GetState} $1 $StartOnBoot
FunctionEnd

Section "Install"
  SetOutPath "$INSTDIR"
  File /r "input\*.*"

  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"
  CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"

  ; Write startup registry only if checkbox selected
  ${If} $StartOnBoot == 1
      WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}" '"$INSTDIR\appproject-overwatch.exe"'
  ${EndIf}

  WriteUninstaller "$INSTDIR\Uninstall.exe"

  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANY}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\${APPNAME}.lnk"
  Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
  RMDir "$SMPROGRAMS\${APPNAME}"

  ; Always remove startup entry on uninstall
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}"

  RMDir /r "$INSTDIR"

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd

