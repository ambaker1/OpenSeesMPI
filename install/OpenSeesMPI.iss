; OpenSeesMPI Inno Setup Script
; Creates the self-extracting installer

#define MyAppName "OpenSeesMPI"
#define MyAppVersion "1.1"
#define MyAppPublisher "Alex Baker"
#include "environment.iss"

[Setup]
AppId={{9233013C-3B5B-461A-84B3-143710FC5BED}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={commonpf64}\OpenSeesMPI
DisableWelcomePage=no
DisableDirPage=no
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputBaseFilename=OpenSeesMPI-{#MyAppVersion}-Setup
OutputDir=.
LicenseFile=../LICENSE.txt
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ChangesEnvironment=true

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\OpenSeesMPI.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\opsmpi.tcl"; DestDir: "{app}"; Flags: ignoreversion 
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\examples\*"; DestDir: "{app}\examples"; Flags: ignoreversion

; Code below by Wojciech Mleczek
; https://stackoverflow.com/a/46609047
[Tasks]
Name: envPath; Description: "Add to PATH variable" 

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
    if (CurStep = ssPostInstall) and WizardIsTaskSelected('envPath')
    then EnvAddPath(ExpandConstant('{app}'));
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
    if CurUninstallStep = usPostUninstall
    then EnvRemovePath(ExpandConstant('{app}'));
end;