!define APP_NAME "Project Overwatch"
!define APP_EXE "appproject-overwatch.exe"
!define APP_DIR "C:\Program Files\${APP_NAME}"

OutFile "project-overwatch-setup.exe"
InstallDir "${APP_DIR}"

RequestExecutionLevel admin
ShowInstDetails show

Section "Install"
  SetOutPath "$INSTDIR"
  File /r "build\Release\*.*"

  ; Create a shortcut on the desktop
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"

  ; Add to Start Menu
  CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
  RMDir "$SMPROGRAMS\${APP_NAME}"
  RMDir /r "$INSTDIR"
SectionEnd

