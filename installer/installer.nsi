!include "MUI2.nsh"
!include "nsDialogs.nsh"

!define APPNAME "Overwatch"
!define COMPANY "Reak"
!define VERSION "1.0.0"

!define INSTALLDIR "$PROGRAMFILES\${COMPANY}\${APPNAME}"

Var StartOnBoot
Var StartOnBootCheckbox

; New vars for uninstall option
Var RemoveUserData
Var RemoveUserDataCheckbox

Name "${APPNAME}"
OutFile "${APPNAME}-Setup.exe"

Icon "input\app.ico"
UninstallIcon "input\app.ico"

InstallDir "${INSTALLDIR}"
RequestExecutionLevel admin

; ------------------------------
; INSTALLER PAGES
; ------------------------------
Page directory
Page custom StartOnBootPage StartOnBootPageLeave
Page instfiles

; ------------------------------
; UNINSTALLER PAGES (MUST begin with un.)
; ------------------------------
UninstPage custom un.UninstallUserDataPage un.UninstallUserDataPageLeave
UninstPage instfiles

; ------------------------------
; STARTUP CHOICE PAGE
; ------------------------------
Function StartOnBootPage
    !insertmacro MUI_HEADER_TEXT "Startup Option" "Choose whether the app starts automatically"

    nsDialogs::Create /NOUNLOAD 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}

    ${NSD_CreateCheckbox} 10u 10u 240u 12u "Run Overwatch at system startup (all users)"
    Pop $StartOnBootCheckbox
    ${NSD_Check} $StartOnBootCheckbox  ; default checked

    nsDialogs::Show
FunctionEnd

Function StartOnBootPageLeave
    ${NSD_GetState} $StartOnBootCheckbox $StartOnBoot
FunctionEnd

; ------------------------------
; UNINSTALL PAGE (must use un.)
; ------------------------------
Function un.UninstallUserDataPage
    !insertmacro MUI_HEADER_TEXT "Uninstall Options" "Choose what to remove"

    nsDialogs::Create /NOUNLOAD 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}

    ${NSD_CreateCheckbox} 10u 10u 300u 12u "Delete user data (database, settings, screenshots)"
    Pop $RemoveUserDataCheckbox
    ${NSD_Uncheck} $RemoveUserDataCheckbox

    nsDialogs::Show
FunctionEnd

Function un.UninstallUserDataPageLeave
    ${NSD_GetState} $RemoveUserDataCheckbox $RemoveUserData
FunctionEnd

; ------------------------------
; INSTALL SECTION
; ------------------------------
Section "Install"

    SetOutPath "$INSTDIR"
    File /r "input\*.*"

    ; Desktop shortcut
    CreateShortCut "$CommonDesktop\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"

    ; Start menu shortcut
    CreateDirectory "$CommonStartMenu\${APPNAME}"
    CreateShortCut "$CommonStartMenu\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"

    ; Auto start
    ${If} $StartOnBoot == 1
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}" "$INSTDIR\appproject-overwatch.exe"
    ${EndIf}

    ; Write uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Programs & Features
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANY}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\Uninstall.exe"

SectionEnd

; ------------------------------
; UNINSTALL SECTION
; ------------------------------
Section "Uninstall"

    DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}"

    Delete "$CommonDesktop\${APPNAME}.lnk"
    Delete "$CommonStartMenu\${APPNAME}\${APPNAME}.lnk"
    RMDir "$CommonStartMenu\${APPNAME}"

    ; Remove installed files
    RMDir /r "$INSTDIR"

    ; Remove Programs & Features entry
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"

    ; Remove AppData only if selected
    ${If} $RemoveUserData == 1
        RMDir /r "$APPDATA\Reak\Overwatch"
    ${EndIf}

SectionEnd

