!include "MUI2.nsh"
!include "nsDialogs.nsh"

!define APPNAME "Overwatch"
!define COMPANY "Reak"
!define VERSION "1.0.0"
!define INSTALLDIR "$PROGRAMFILES\${COMPANY}\${APPNAME}"

Var StartOnBoot
Var StartOnBootCheckbox

Name "${APPNAME}"
OutFile "${APPNAME}-Setup.exe"

Icon "input\app.ico"
UninstallIcon "input\app.ico"

InstallDir "${INSTALLDIR}"
RequestExecutionLevel admin

Page directory
Page custom StartOnBootPage StartOnBootPageLeave
Page instfiles

; --- Start on Boot Checkbox Page ---
Function StartOnBootPage
    !insertmacro MUI_HEADER_TEXT "Startup Option" "Choose whether the app starts with Windows"

    nsDialogs::Create /NOUNLOAD 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}

    ${NSD_CreateCheckbox} 10u 10u 200u 12u "Run Overwatch at system startup"
    Pop $StartOnBootCheckbox
    ${NSD_Check} $StartOnBootCheckbox ; default checked

    nsDialogs::Show
FunctionEnd

Function StartOnBootPageLeave
    ${NSD_GetState} $StartOnBootCheckbox $StartOnBoot
FunctionEnd

; --- Install Section ---
Section "Install"
    SetOutPath "$INSTDIR"
    File /r "input\*.*"

    ; Start Menu & Desktop shortcuts
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"
    CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"

    ; Startup shortcut if checkbox selected
    ${If} $StartOnBoot == 1
        CreateDirectory "$SMSTARTUP"
        CreateShortcut "$SMSTARTUP\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"
    ${EndIf}

    ; Write uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Add entry to Programs & Features
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANY}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
SectionEnd

; --- Uninstall Section ---
Section "Uninstall"
    ; Remove Desktop & Start Menu shortcuts
    Delete "$DESKTOP\${APPNAME}.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
    RMDir "$SMPROGRAMS\${APPNAME}"

    ; Remove Startup shortcut
    Delete "$SMSTARTUP\${APPNAME}.lnk"

    ; Remove installation folder
    RMDir /r "$INSTDIR"

    ; Remove Programs & Features entry
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd

