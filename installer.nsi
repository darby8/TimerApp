!define APP_NAME "Project Overwatch"
!define APP_EXE "appproject-overwatch.exe"
!define APP_DIR "C:\Program Files\${APP_NAME}"

OutFile "project-overwatch-setup.exe"
InstallDir "${APP_DIR}"
RequestExecutionLevel admin
ShowInstDetails show

Section "Install"
  SetOutPath "$INSTDIR"
  File /r "installer\input\*.*"

  ; Desktop shortcut
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"

  ; Start Menu shortcut
  CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
  RMDir "$SMPROGRAMS\${APP_NAME}"
  RMDir /r "$INSTDIR"
SectionEnd

