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
; PAGES
; ------------------------------
Page directory
Page custom StartOnBootPage StartOnBootPageLeave
Page instfiles

; ------------------------------
; UNINSTALL PAGES
; (custom page to ask about removing user data)
; ------------------------------
UninstPage custom UninstallUserDataPage UninstallUserDataPageLeave
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
; UNINSTALL: Ask whether to remove user data
; ------------------------------
Function UninstallUserDataPage
    !insertmacro MUI_HEADER_TEXT "Uninstall Options" "Choose what to remove"

    nsDialogs::Create /NOUNLOAD 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}

    ${NSD_CreateCheckbox} 10u 10u 300u 12u "Delete user data (database, settings, screenshots)"
    Pop $RemoveUserDataCheckbox
    ${NSD_Uncheck} $RemoveUserDataCheckbox  ; default unchecked

    nsDialogs::Show
FunctionEnd

Function UninstallUserDataPageLeave
    ${NSD_GetState} $RemoveUserDataCheckbox $RemoveUserData
FunctionEnd

; ------------------------------
; INSTALL SECTION
; ------------------------------
Section "Install"

    SetOutPath "$INSTDIR"
    File /r "input\*.*"

    ; --------------------------
    ; CREATE SHORTCUTS FOR ALL USERS
    ; --------------------------
    ; Desktop
    CreateShortCut "$CommonDesktop\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"

    ; Start Menu folder
    CreateDirectory "$CommonStartMenu\${APPNAME}"
    CreateShortCut "$CommonStartMenu\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"

    ; --------------------------
    ; AUTO START (HKLM RUN)
    ; --------------------------
    ${If} $StartOnBoot == 1
        WriteRegStr HKLM \
            "Software\Microsoft\Windows\CurrentVersion\Run" \
            "${APPNAME}" \
            "$INSTDIR\appproject-overwatch.exe"
    ${EndIf}

    ; --------------------------
    ; WRITE UNINSTALLER
    ; --------------------------
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Programs & Features entry
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
    ; Remove AUTO-START
    DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}"

    ; Remove shortcuts (ALL USERS)
    Delete "$CommonDesktop\${APPNAME}.lnk"
    Delete "$CommonStartMenu\${APPNAME}\${APPNAME}.lnk"
    RMDir "$CommonStartMenu\${APPNAME}"

    ; Remove installed files
    RMDir /r "$INSTDIR"

    ; Remove Programs & Features entry
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"

    ; --------------------------
    ; OPTIONAL: Remove user data stored in %APPDATA%\Reak\Overwatch
    ; This is where QStandardPaths::AppDataLocation typically maps to for your app:
    ;   C:\Users\<User>\AppData\Roaming\Reak\Overwatch
    ; --------------------------
    ${If} $RemoveUserData == 1
        ; Remove the entire folder recursively (database, screenshots, settings)
        RMDir /r "$APPDATA\Reak\Overwatch"
    ${EndIf}

SectionEnd

