!include "MUI2.nsh"

!define APPNAME "Overwatch"
!define COMPANY "Reak"
!define VERSION "1.0.0"
!define INSTALLDIR "$PROGRAMFILES\${COMPANY}\${APPNAME}"

# --------------------------
# Installer Information
# --------------------------
Name "${APPNAME}"
OutFile "${APPNAME}-Setup.exe"

# 🔥 Set installer icon
Icon "input\app.ico"            ; Icon for installer EXE
UninstallIcon "input\app.ico"   ; Icon for uninstall EXE

InstallDir "${INSTALLDIR}"
RequestExecutionLevel admin

# --------------------------
# Installer Pages
# --------------------------
Page Directory
Page InstFiles

# --------------------------
# Install Section
# --------------------------
Section "Install"
  SetOutPath "$INSTDIR"
  File /r "input\*.*"

  # 🔥 Add Start Menu folder and shortcuts
  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"
  CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\appproject-overwatch.exe"

  # 🔥 Add uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  # 🔥 Write Control Panel uninstall registry entries
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANY}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
SectionEnd

# --------------------------
# Uninstall Section
# --------------------------
Section "Uninstall"
  Delete "$DESKTOP\${APPNAME}.lnk"
  Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
  RMDir  "$SMPROGRAMS\${APPNAME}"

  RMDir /r "$INSTDIR"

  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd

