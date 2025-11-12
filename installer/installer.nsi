!include "MUI2.nsh"

!define APPNAME "OverwatchApp"
!define COMPANY "YourCompany"
!define VERSION "1.0.0"
!define INSTALLDIR "$PROGRAMFILES\${COMPANY}\${APPNAME}"

Name "${APPNAME}"
OutFile "${APPNAME}-Setup.exe"
InstallDir "${INSTALLDIR}"

RequestExecutionLevel admin

Page Directory
Page InstFiles

Section "Install"
  SetOutPath "$INSTDIR"
  File /r "input\*.*"
  CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"
SectionEnd

Section "Uninstall"
  Delete "$DESKTOP\${APPNAME}.lnk"
  RMDir /r "$INSTDIR"
SectionEnd

