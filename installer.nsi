!define APPNAME "YourApp"
!define COMPANY "YourCompany"
!define VERSION "1.0.0"
!define INSTALL_DIR "$PROGRAMFILES64\${COMPANY}\${APPNAME}"

OutFile "${APPNAME}_Setup_${VERSION}.exe"
InstallDir "${INSTALL_DIR}"
RequestExecutionLevel admin

Page directory
Page instfiles

Section "Install"
  SetOutPath "$INSTDIR"
  File /r "install\*.*"
  CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\bin\apptest_qt.exe"
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\${APPNAME}.lnk"
  RMDir /r "$INSTDIR"
SectionEnd
