Unicode true
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

!cd "${__FILEDIR__}"

Name "Sadaqah Path"
OutFile "..\dist\Sadaqah-Path-2.1.2-Setup.exe"
InstallDir "$LOCALAPPDATA\Sadaqah Path Setup"
RequestExecutionLevel user
SetCompressor /SOLID lzma
Icon "..\assets\icon.ico"

VIProductVersion "2.1.2.0"
VIAddVersionKey /LANG=1033 "ProductName" "Sadaqah Path"
VIAddVersionKey /LANG=1033 "FileDescription" "Sadaqah Path multilingual installer"
VIAddVersionKey /LANG=1033 "CompanyName" "ET TECH"
VIAddVersionKey /LANG=1033 "FileVersion" "2.1.2"

!define MUI_ABORTWARNING
!define MUI_LANGDLL_ALLLANGUAGES
!define MUI_LANGDLL_WINDOWTITLE "Sadaqah Path — Setup Language"
!define MUI_LANGDLL_INFO "Choose your setup language:"
!define MUI_ICON "..\assets\icon.ico"

Var Arch64Radio
Var Arch32Radio
Var SelectedArch
Var ArchTitleText
Var ArchSubtitleText
Var Arch64Text
Var Arch32Text
Var Arch32OnlyText
Var InstallingText
Var InstallFailedText
Var ArchInfoLabel

!insertmacro MUI_PAGE_WELCOME
Page custom ArchitecturePageCreate ArchitecturePageLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Arabic"

Function .onInit
  StrCpy $LANGUAGE ${LANG_ENGLISH}
  !insertmacro MUI_LANGDLL_DISPLAY
  StrCpy $SelectedArch "x64"
FunctionEnd

Function SetArchitectureTexts
  ${If} $LANGUAGE == ${LANG_ARABIC}
    StrCpy $ArchTitleText "اختر نسخة Windows"
    StrCpy $ArchSubtitleText "اختر النسخة المناسبة لجهازك."
    StrCpy $Arch64Text "64-bit — موصى بها لمعظم الأجهزة الحديثة"
    StrCpy $Arch32Text "32-bit — للأجهزة القديمة أو Windows 32-bit"
    StrCpy $Arch32OnlyText "هذا الجهاز يعمل بنظام Windows 32-bit، لذلك يمكن تثبيت نسخة 32-bit فقط."
    StrCpy $InstallingText "جاري تثبيت Sadaqah Path..."
    StrCpy $InstallFailedText "لم يكتمل التثبيت بنجاح. رمز الخطأ:"
  ${ElseIf} $LANGUAGE == ${LANG_GERMAN}
    StrCpy $ArchTitleText "Windows-Version auswählen"
    StrCpy $ArchSubtitleText "Wähle die passende Version für deinen Computer."
    StrCpy $Arch64Text "64-Bit — empfohlen für die meisten modernen Computer"
    StrCpy $Arch32Text "32-Bit — für ältere Computer oder 32-Bit-Windows"
    StrCpy $Arch32OnlyText "Auf diesem Computer läuft 32-Bit-Windows. Daher kann nur die 32-Bit-Version installiert werden."
    StrCpy $InstallingText "Sadaqah Path wird installiert..."
    StrCpy $InstallFailedText "Die Installation wurde nicht erfolgreich abgeschlossen. Fehlercode:"
  ${Else}
    StrCpy $ArchTitleText "Choose Windows version"
    StrCpy $ArchSubtitleText "Choose the version that matches your computer."
    StrCpy $Arch64Text "64-bit — recommended for most modern computers"
    StrCpy $Arch32Text "32-bit — for older computers or 32-bit Windows"
    StrCpy $Arch32OnlyText "This computer runs 32-bit Windows, so only the 32-bit version can be installed."
    StrCpy $InstallingText "Installing Sadaqah Path..."
    StrCpy $InstallFailedText "Installation did not complete successfully. Error code:"
  ${EndIf}
FunctionEnd

Function ArchitecturePageCreate
  Call SetArchitectureTexts
  !insertmacro MUI_HEADER_TEXT "$ArchTitleText" "$ArchSubtitleText"
  nsDialogs::Create 1018
  Pop $0
  ${If} $0 == error
    Abort
  ${EndIf}
  ${NSD_CreateRadioButton} 12u 22u 94% 22u "$Arch64Text"
  Pop $Arch64Radio
  ${NSD_CreateRadioButton} 12u 58u 94% 22u "$Arch32Text"
  Pop $Arch32Radio
  ${If} ${RunningX64}
    ${NSD_Check} $Arch64Radio
    StrCpy $SelectedArch "x64"
  ${Else}
    EnableWindow $Arch64Radio 0
    ${NSD_Check} $Arch32Radio
    StrCpy $SelectedArch "ia32"
    ${NSD_CreateLabel} 12u 96u 94% 44u "$Arch32OnlyText"
    Pop $ArchInfoLabel
  ${EndIf}
  nsDialogs::Show
FunctionEnd

Function ArchitecturePageLeave
  ${NSD_GetState} $Arch32Radio $0
  ${If} $0 == ${BST_CHECKED}
    StrCpy $SelectedArch "ia32"
  ${Else}
    StrCpy $SelectedArch "x64"
  ${EndIf}
FunctionEnd

Section "Install"
  Call SetArchitectureTexts
  DetailPrint "$InstallingText"
  InitPluginsDir
  CreateDirectory "$APPDATA\Sadaqah Path"
  FileOpen $1 "$APPDATA\Sadaqah Path\preferred-language.txt" w
  ${If} $LANGUAGE == ${LANG_ARABIC}
    FileWrite $1 "ar"
  ${ElseIf} $LANGUAGE == ${LANG_GERMAN}
    FileWrite $1 "de"
  ${Else}
    FileWrite $1 "en"
  ${EndIf}
  FileClose $1

  SetOutPath "$PLUGINSDIR"
  ${If} $SelectedArch == "ia32"
    File /oname=SadaqahPathChild.exe "..\dist\Sadaqah-Path-2.1.2-Child-ia32.exe"
  ${Else}
    File /oname=SadaqahPathChild.exe "..\dist\Sadaqah-Path-2.1.2-Child-x64.exe"
  ${EndIf}

  ExecWait '"$PLUGINSDIR\SadaqahPathChild.exe" /S' $0
  ${If} $0 != 0
    MessageBox MB_ICONSTOP|MB_OK "$InstallFailedText $0"
    SetErrorLevel $0
    Abort
  ${EndIf}
SectionEnd
