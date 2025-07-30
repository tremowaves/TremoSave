[Setup]
AppName=Tremo Save
AppVersion=1.0.0
AppPublisher=Tremowaves
AppPublisherURL=https://tremowaves.com
AppSupportURL=https://tremowaves.com
AppUpdatesURL=https://tremowaves.com
AppId={{TREMO-SAVE-2024-01-01}
DefaultDirName={autopf}\Tremo Save
DefaultGroupName=Tremo Save
AllowNoIcons=yes
LicenseFile=
InfoBeforeFile=
InfoAfterFile=
OutputDir=installer
OutputBaseFilename=TremoSave_Setup_v1.0.0
SetupIconFile=assets\AppIcon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
MinVersion=10.0
DisableProgramGroupPage=no
DisableDirPage=no
DisableWelcomePage=no
WizardResizable=yes
WizardImageFile=
WizardSmallImageFile=

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode
Name: "startupicon"; Description: "Start Tremo Save when Windows starts"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "build\windows\x64\runner\Release\TremoSave.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Tremo Save"; Filename: "{app}\TremoSave.exe"; WorkingDir: "{app}"
Name: "{group}\{cm:UninstallProgram,Tremo Save}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Tremo Save"; Filename: "{app}\TremoSave.exe"; WorkingDir: "{app}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\Tremo Save"; Filename: "{app}\TremoSave.exe"; WorkingDir: "{app}"; Tasks: quicklaunchicon
Name: "{commonstartup}\Tremo Save"; Filename: "{app}\TremoSave.exe"; WorkingDir: "{app}"; Tasks: startupicon

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "Tremo Save"; ValueData: """{app}\TremoSave.exe"""; Tasks: startupicon; Flags: uninsdeletevalue
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "Tremo Save"; ValueData: ""; Tasks: startupicon; Flags: uninsdeletevalue; Check: not IsTaskSelected('startupicon')

[Run]
Filename: "{app}\TremoSave.exe"; Description: "{cm:LaunchProgram,Tremo Save}"; Flags: nowait postinstall skipifsilent; WorkingDir: "{app}"

[UninstallDelete]
Type: files; Name: "{app}\*.log"
Type: files; Name: "{app}\*.tmp"
Type: dirifempty; Name: "{app}"

[Code]
var
  WelcomePage: TOutputMsgWizardPage;

procedure InitializeWizard;
begin
  WelcomePage := CreateOutputMsgPage(wpWelcome,
    'Welcome to Tremo Save Setup', 'This will install Tremo Save on your computer.',
'Tremo Save is a powerful application that helps you automatically save your work and manage your files efficiently.' + #13#10#13#10 +
    'Click Next to continue with the installation.');
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpWelcome then
  begin
    // Add any custom validation here
  end;
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  
  // Check if .NET Framework is available (if needed)
  // if not IsDotNetDetected('4.5', 0) then
  // begin
  //   MsgBox('This application requires .NET Framework 4.5 or later.' + #13#10 +
  //          'Please install .NET Framework and run this installer again.', mbInformation, MB_OK);
  //   Result := False;
  // end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Post-installation tasks
    Log('Tremo Save installation completed successfully');
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Post-uninstallation tasks
    Log('Tremo Save uninstallation completed');
  end;
end; 