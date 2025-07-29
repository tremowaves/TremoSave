[Setup]
AppName=Tremo Save
AppVersion=1.0.0
AppPublisher=Tremowaves
AppPublisherURL=https://tremowaves.com
AppSupportURL=https://tremowaves.com
AppUpdatesURL=https://tremowaves.com
DefaultDirName={autopf}\Tremo Save
DefaultGroupName=Tremo Save
AllowNoIcons=yes
LicenseFile=
InfoBeforeFile=
InfoAfterFile=
OutputDir=installer
OutputBaseFilename=TremoSave_Setup
SetupIconFile=assets\AppIcon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
Source: "build\windows\x64\runner\Release\auto_saver.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Tremo Save"; Filename: "{app}\auto_saver.exe"
Name: "{group}\{cm:UninstallProgram,Tremo Save}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Tremo Save"; Filename: "{app}\auto_saver.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\Tremo Save"; Filename: "{app}\auto_saver.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\auto_saver.exe"; Description: "{cm:LaunchProgram,Tremo Save}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end; 