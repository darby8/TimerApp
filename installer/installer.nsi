!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"

!define APPNAME "Overwatch"
!define COMPANY "Reak"
!define VERSION "1.0.0"
!define INSTALLDIR "$PROGRAMFILES\${COMPANY}\${APPNAME}"

Var StartOnBoot
Var RemoveUserData
Var RemoveUserDataCheckbox

Name "${APPNAME}"
OutFile "${APPNAME}-Setup.exe"

InstallDir "${INSTALLDIR}"

!define MUI_ABORTWARNING
!define MUI_ICON "input\app.ico"
!define MUI_UNICON "input\app.ico"

; -----------------------------
; INSTALLER PAGES
; -----------------------------
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY

Page custom StartOnBootPage StartOnBootPageLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; -----------------------------
; UNINSTALLER PAGES
; -----------------------------
UninstPage custom UninstallUserDataPage UninstallUserDataPageLeave
UninstPage instfiles

; -----------------------------
; START ON BOOT PAGE
; -----------------------------
Function StartOnBootPage
    !insertmacro MUI_HEADER_TEXT "Startup Option" "Choose if app starts with Windows"

    nsDialogs::Create 1018
    Pop $0

    ${NSD_CreateCheckbox} 10u 10u 260u 12u "Start ${APPNAME} automatically at system startup"
    Pop $StartOnBoot
    ${NSD_Uncheck} $StartOnBoot

    nsDialogs::Show
FunctionEnd

Function StartOnBootPageLeave
    ${NSD_GetState} $StartOnBoot $StartOnBoot
FunctionEnd

; -----------------------------
; UNINSTALLER DELETE USER DATA PAGE
; -----------------------------
Function UninstallUserDataPage
    !insertmacro MUI_HEADER_TEXT "Uninstall Options" "Choose what to remove"

    nsDialogs::Create /NOUNLOAD 1018
    Pop $0

    ${NSD_CreateCheckbox} 10u 10u 260u 12u "Delete user data (database, settings, screenshots)"
    Pop $RemoveUserDataCheckbox
    ${NSD_Uncheck} $RemoveUserDataCheckbox

    nsDialogs::Show
FunctionEnd

Function UninstallUserDataPageLeave
    ${NSD_GetState} $RemoveUserDataCheckbox $RemoveUserData
FunctionEnd

; -----------------------------
; INSTALL SECTION
; -----------------------------
Section "Install"

    SetOutPath "$INSTDIR"

    File /r "input\*.*"

    ; Add to Programs & Features
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
        "DisplayName" "${APPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
        "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
        "Publisher" "${COMPANY}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
        "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" \
        "UninstallString" "$INSTDIR\Uninstall.exe"

    ; Startup option
    ${If} $StartOnBoot == 1
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}" "$INSTDIR\appproject-overwatch.exe"
    ${EndIf}

    ; Shortcuts
    CreateDirectory "$CommonStartMenu\${APPNAME}"
    CreateShortCut "$CommonStartMenu\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"
    CreateShortCut "$CommonDesktop\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"

SectionEnd

; -----------------------------
; UNINSTALL SECTION
; -----------------------------
Section "Uninstall"

    ; Remove autorun
    DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}"

    ; Remove shortcuts
    Delete "$CommonDesktop\${APPNAME}.lnk"
    Delete "$CommonStartMenu\${APPNAME}\${APPNAME}.lnk"
    RMDir "$CommonStartMenu\${APPNAME}"

    ; Remove installed program files
    RMDir /r "$INSTDIR"

    ; Remove Programs & Features entry
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"

    ; -----------------------------------
    ; DELETE USER DATA (if checked)
    ; -----------------------------------
    ${If} $RemoveUserData == 1
        RMDir /r "$APPDATA\Reak\Overwatch"
    ${EndIf}

SectionEnd

