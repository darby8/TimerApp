; installer.nsi
; NSIS script for appproject-overwatch
; - copies all files from installer/input into installation directory
; - creates shortcuts
; - sets QML2_IMPORT_PATH for current user & creates run.bat launcher
; - uninstall removes env var and installed files

!include "WinMessages.nsh"
!include "LogicLib.nsh"

Name "appproject-overwatch"
OutFile "appproject-overwatch-setup.exe"
InstallDir "$PROGRAMFILES64\Reak\appproject-overwatch"
RequestExecutionLevel admin
ShowInstDetails show

!define APP_EXE "appproject-overwatch.exe"
!define LAUNCHER "run.bat"

Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Section "Install"

  ; Create install dir
  SetOutPath "$INSTDIR"
  ; copy everything from build staging folder created by pipeline (installer/input)
  ; Make sure your pipeline populates installer/input with the portable build contents
  File /r "installer/input\*.*"

  ; Create a run.bat that sets QML2_IMPORT_PATH and starts the exe
  ; This ensures local imports like "import './pages'" work when run from Start Menu
  ClearErrors
  Push "$INSTDIR\${LAUNCHER}"
  Pop $0
  ; Write run.bat content
  ; We use Windows cmd variable %~dp0 to get script dir, then set QML2_IMPORT_PATH and launch exe
  ; Note: the caret (^) escapes newlines in NSIS WriteIniStr-like approach, so we use FileOpen/FileWrite for reliability.
  FileOpen $0 "$INSTDIR\${LAUNCHER}" w
  FileWrite $0 '@echo off$\r\n'
  FileWrite $0 'setlocal enableextensions$\r\n'
  FileWrite $0 'set "QML2_IMPORT_PATH=%~dp0qml"%\r\n' ; ensure qml path is relative to installer root
  FileWrite $0 'set "PATH=%~dp0;%PATH%"$\r\n'
  FileWrite $0 'start "" "%~dp0\${APP_EXE}"$\r\n'
  FileWrite $0 'endlocal$\r\n'
  FileClose $0

  ; Create Start Menu folder
  CreateDirectory "$SMPROGRAMS\appproject-overwatch"
  ; Create Start Menu shortcut that runs the run.bat
  CreateShortcut "$SMPROGRAMS\appproject-overwatch\appproject-overwatch.lnk" "$INSTDIR\${LAUNCHER}" "" "$INSTDIR\${APP_EXE}" 0

  ; Create Desktop shortcut pointing directly to exe (optional)
  CreateShortCut "$DESKTOP\appproject-overwatch.lnk" "$INSTDIR\${APP_EXE}" "" "$INSTDIR\${APP_EXE}" 0

  ; Write environment variable for current user so other launches can find QML imports
  ; (Write to HKCU\Environment)
  WriteRegStr HKCU "Environment" "QML2_IMPORT_PATH" "$INSTDIR\qml"

  ; Broadcast environment change to running apps (so Start Menu picks it up)
  ; Use System plugin call to SendMessageTimeout with WM_SETTINGCHANGE
  System::Call 'user32::SendMessageTimeout(i 0xffff, i ${WM_SETTINGCHANGE}, i 0, t "Environment", i 0, i 1000, *i .r0)'

  ; Create an Uninstall entry
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\appproject-overwatch" "DisplayName" "appproject-overwatch"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\appproject-overwatch" "UninstallString" "$INSTDIR\uninstall.exe"

  ; Optionally run the app after install
  ; ExecShell open "$INSTDIR\${LAUNCHER}"
  ; If you prefer to auto-run the app immediately, uncomment below:
  Exec '"$INSTDIR\${LAUNCHER}"'

SectionEnd

Section "Uninstall"

  ; Run uninstall actions
  ; Delete shortcuts
  Delete "$DESKTOP\appproject-overwatch.lnk"
  Delete "$SMPROGRAMS\appproject-overwatch\appproject-overwatch.lnk"
  RMDir "$SMPROGRAMS\appproject-overwatch"

  ; Remove files and directories under $INSTDIR
  RMDir /r "$INSTDIR"

  ; Remove registry uninstall entry
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\appproject-overwatch"

  ; Remove the environment variable we created (HKCU)
  DeleteRegValue HKCU "Environment" "QML2_IMPORT_PATH"

  ; Broadcast environment change again
  System::Call 'user32::SendMessageTimeout(i 0xffff, i ${WM_SETTINGCHANGE}, i 0, t "Environment", i 0, i 1000, *i .r0)'

SectionEnd

