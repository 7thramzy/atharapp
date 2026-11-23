#define AppName "Athaar"
#ifndef AppVersion
  #define AppVersion "0.1.0"
#endif
#define AppExeName "athaar.exe"
#define AppOutputDir GetEnv("ATHAAR_BUILD_DIR")
#define InstallerOutputDir GetEnv("ATHAAR_INSTALLER_DIR")
#define VCRedistPath GetEnv("ATHAAR_VC_REDIST")

[Setup]
AppId={{C8B24F20-5F7C-4F4A-90A5-BDCCB7C19A21}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=Athaar Project
DefaultDirName={autopf}\Athaar
DefaultGroupName=Athaar
UninstallDisplayIcon={app}\{#AppExeName}
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
DisableProgramGroupPage=yes
WizardStyle=modern
Compression=lzma2
SolidCompression=yes
OutputDir={#InstallerOutputDir}
OutputBaseFilename=Athaar-Setup-{#AppVersion}
SetupLogging=yes
CloseApplications=yes

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Files]
Source: "{#AppOutputDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#VCRedistPath}"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{autoprograms}\Athaar"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\Athaar"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Microsoft Visual C++ runtime..."; Check: NeedsVCRedist; Flags: waituntilterminated runhidden ignoreerrors
Filename: "{app}\{#AppExeName}"; Description: "Launch Athaar"; Flags: postinstall nowait skipifsilent

[Code]
function NeedsVCRedist: Boolean;
var
  Installed: Cardinal;
begin
  Result := not (RegQueryDWordValue(HKLM64, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Installed', Installed) and (Installed = 1));
end;
