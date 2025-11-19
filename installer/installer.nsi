!include "MUI2.nsh"
!include "LogicLib.nsh"

!define APPNAME "Overwatch"
!define COMPANY "Reak"
!define VERSION "1.0.0"
!define INSTALLDIR "$PROGRAMFILES\${COMPANY}\${APPNAME}"

Name "${APPNAME}"
OutFile "${APPNAME}.exe"

Icon "input\app.ico"
UninstallIcon "input\app.ico"

InstallDir "${INSTALLDIR}"
RequestExecutionLevel admin

# --------------------------
# Installer Pages
# --------------------------
Page Directory
Page InstFiles
!insertmacro MUI_PAGE_FINISH

# ⭐ FINISH PAGE CHECKBOX (Autostart)
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Start Overwatch on Windows startup"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION AutoStartCheckboxSelected

# ⭐ FINISH PAGE CHECKBOX (Run Now)
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Launch Overwatch now"
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchAppNow

# --------------------------
# Install Section
# --------------------------
Section "Install"

  SetOutPath "$INSTDIR"
  File /r "input\*.*"

  ; Shortcuts
  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"
  CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"

  ; Uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; Uninstall info
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANY}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\Uninstall.exe"

SectionEnd

# --------------------------
# Checkbox: Auto-start On Windows Boot
# --------------------------
Function AutoStartCheckboxSelected
    ; MUI stores this checkbox in $mui.FinishPage.ReadmeCheck
    ${NSD_GetState} $mui.FinishPage.ReadmeCheck $0

    ${If} $0 == ${BST_CHECKED}
        WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}" "$INSTDIR\appproject-overwatch.exe"
    ${EndIf}
FunctionEnd

# --------------------------
# Checkbox: Launch App After Install
# --------------------------
Function LaunchAppNow
    ; Run now checkbox is stored in $mui.FinishPage.RunCheck
    ${NSD_GetState} $mui.FinishPage.RunCheck $0

    ${If} $0 == ${BST_CHECKED}
        Exec "$INSTDIR\appproject-overwatch.exe"
    ${EndIf}
FunctionEnd

# --------------------------
# Uninstall Section
# --------------------------
Section "Uninstall"

  Delete "$DESKTOP\${APPNAME}.lnk"
  Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
  RMDir  "$SMPROGRAMS\${APPNAME}"

  ; Remove autostart
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}"

  RMDir /r "$INSTDIR"

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"

SectionEnd

