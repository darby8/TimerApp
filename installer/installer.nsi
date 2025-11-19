!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!insertmacro GetParameters

!define APPNAME "Overwatch"
!define COMPANY "Reak"
!define VERSION "1.0.0"
!define APP_EXE "appproject-overwatch.exe"
!define INSTALLDIR "$PROGRAMFILES\${COMPANY}\${APPNAME}"

Name "${APPNAME}"
OutFile "${APPNAME}-Setup.exe"

Icon "input\\app.ico"
UninstallIcon "input\\app.ico"

InstallDir "${INSTALLDIR}"
RequestExecutionLevel admin

; --------------------------
; Installer Pages
; --------------------------
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "license.txt" ; optional - remove if not used
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Finish page checkboxes (autostart + run now)
!define MUI_FINISHPAGE_SHOWREADME
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Start Overwatch on Windows startup"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION AutoStartCheckboxSelected

!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Launch Overwatch now"
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchAppNow

; --------------------------
; Initialization - check previous install
; --------------------------
Function .onInit
  ; Check registry for previous install location
  ReadRegStr $0 HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APPNAME}" "InstallLocation"
  StrCmp $0 "" no_old_install
    ; If EXE exists in old location, prompt to uninstall
    IfFileExists "$0\\${APP_EXE}" 0 no_old_install
    MessageBox MB_YESNO|MB_ICONQUESTION "${APPNAME} appears to be installed at $0. Do you want to uninstall the previous version now?" IDYES do_uninstall
    goto done
    do_uninstall:
      ; Try to run previous uninstaller silently (best-effort)
      ExecWait '"$0\\Uninstall.exe"'
  no_old_install:
  done:
FunctionEnd

; --------------------------
; Install Section
; --------------------------
Section "Install"
  SetOutPath "$INSTDIR"

  ; Copy all files provided in "input" folder (GitHub workflow populates installer/input)
  File /r "input\\*.*"

  ; Create Start Menu & Desktop Shortcuts
  CreateDirectory "$SMPROGRAMS\\${APPNAME}"
  CreateShortcut "$SMPROGRAMS\\${APPNAME}\\${APPNAME}.lnk" "$INSTDIR\\${APP_EXE}"
  CreateShortcut "$DESKTOP\\${APPNAME}.lnk" "$INSTDIR\\${APP_EXE}"

  ; Write an uninstaller file into $INSTDIR (this file will be embedded into installer by NSIS)
  ; Also, for CI convenience, attempt to write Uninstall.exe next to the installer at compile-time if possible:
  ; Primary uninstaller will be written to "$INSTDIR\\Uninstall.exe" (runtime). We also write a copy to the compile folder:
  WriteUninstaller "$INSTDIR\\Uninstall.exe"

  ; Register Control Panel uninstall info
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APPNAME}" "DisplayName" "${APPNAME}"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APPNAME}" "Publisher" "${COMPANY}"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APPNAME}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APPNAME}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APPNAME}" "UninstallString" "$INSTDIR\\Uninstall.exe"
SectionEnd

; --------------------------
; Finish page: Auto-start checkbox handler
; --------------------------
Function AutoStartCheckboxSelected
  ; MUI stores these finish-page checkboxes internally; use NSD_GetState on the generated widgets.
  ; The MUI finishpage generates variables $mui.FinishPage.ReadmeCheck and $mui.FinishPage.RunCheck.
  ; Use ${NSD_GetState} to read them.
  ${If} ${NSD_GetState} $mui.FinishPage.ReadmeCheck $0
    ; If NSD_GetState returned 1 meaning the widget exists, check value
  ${EndIf}
  ; Read state safely:
  ${NSD_GetState} $mui.FinishPage.ReadmeCheck $0
  ${If} $0 == ${BST_CHECKED}
    WriteRegStr HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Run" "${APPNAME}" "$INSTDIR\\${APP_EXE}"
  ${EndIf}
FunctionEnd

; --------------------------
; Finish page: Launch now handler
; --------------------------
Function LaunchAppNow
  ${NSD_GetState} $mui.FinishPage.RunCheck $0
  ${If} $0 == ${BST_CHECKED}
    Exec "$INSTDIR\\${APP_EXE}"
  ${EndIf}
FunctionEnd

; --------------------------
; Uninstall Section
; --------------------------
Section "Uninstall"
  ; Remove shortcuts
  Delete "$DESKTOP\\${APPNAME}.lnk"
  Delete "$SMPROGRAMS\\${APPNAME}\\${APPNAME}.lnk"
  RMDir "$SMPROGRAMS\\${APPNAME}"

  ; Remove autostart entry if present
  DeleteRegValue HKCU "Software\\Microsoft\\Windows\\CurrentVersion\\Run" "${APPNAME}"

  ; Remove installed files
  RMDir /r "$INSTDIR"

  ; Remove Control Panel entry
  DeleteRegKey HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APPNAME}"
SectionEnd

