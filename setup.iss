#define MyAppVersion "1.6.3"
#define OSGVersion "2.8.5"
#define OSGSOVersion "74"
#define OTSOVersion "11"

#define MyAppName "SketchUp to OpenSceneGraph Exporter Plugin - SketchUp " + TARGET_VERSION
#define MyAppPublisher "Ryan Pavlik"
#define MyAppPublisherURL "http://ryanpavlik.com"
#define MyAppURL "http://github.com/rpavlik/sketchupToOSG"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppID={#VersionSpecificGUID}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppPublisherURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={code:GetSketchUpPluginsDir}
DisableDirPage=yes
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputBaseFilename=setup-sketchupToOpenSceneGraphPlugin-{#MyAppVersion}-skp{#TARGET_VERSION}
Compression=lzma/Max
SolidCompression=true
DirExistsWarning=no
AppendDefaultDirName=false
AlwaysShowDirOnReadyPage=true
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}
UninstallFilesDir={app}\osgconv

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; Files created for this project
Source: "openscenegraph_exportviacollada.rb"; DestDir: "{app}"; Flags: ignoreversion
Source: README.mkd; DestDir: {app}; Flags: ignoreversion; DestName: SketchupToOpenSceneGraph-README.txt; 
Source: "osgconv\fileutils.rb"; DestDir: "{app}\osgconv"; Flags: ignoreversion
Source: "osgconv\LICENSE_1_0.txt"; DestDir: "{app}\osgconv"; Flags: ignoreversion
Source: "osgconv\osgconv.rb"; DestDir: "{app}\osgconv"; Flags: ignoreversion

; OpenSceneGraph
Source: "osgconv\osg{#OSGSOVersion}-*.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion; 
Source: "osgconv\ot{#OTSOVersion}-OpenThreads.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;
Source: "osgconv\osgPlugins-{#OSGVersion}\*.dll"; DestDir: "{app}\osgconv\osgPlugins-{#OSGVersion}"; Flags: IgnoreVersion;

; OSG Executables
Source: "osgconv\osgconv.exe"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;
Source: "osgconv\osgviewer.exe"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;

; OSG Dependencies
Source: "osgconv\freetype6.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;
Source: "osgconv\jpeg62.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;
Source: "osgconv\libcollada14dom22.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;
Source: "osgconv\libpng12.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;
Source: "osgconv\libtiff3.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;
Source: "osgconv\libungif4.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;
Source: "osgconv\libxml2.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;
Source: "osgconv\libungif4.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;
Source: "osgconv\zlib1.dll"; DestDir: "{app}\osgconv"; Flags: IgnoreVersion;

[Icons]
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Code]
var
  SketchUpPluginsDir: String;

function GetSketchUpPluginsDir(Param: String): String;
begin
  Result := SketchUpPluginsDir;
end;

function IsValidDir(): Boolean;
begin
  Result := DirExists(SketchUpPluginsDir) and FileExists(SketchUpPluginsDir  + '\..\SketchUp.exe');
end;

function InitializeSetup(): Boolean;
var                                              
  KeepAsking: Boolean;
begin
  Result := True;                                                                
  SketchUpPluginsDir := ExpandConstant('{#DEFAULT_LOCATION}');
  KeepAsking := not IsValidDir();
  while Result and KeepAsking do begin
    SketchUpPluginsDir := ExpandConstant('{#DEFAULT_LOCATION}');
    Result := BrowseForFolder('Could not find the SketchUp {#TARGET_VERSION} plugin directory: please select it',
      SketchUpPluginsDir, False);
    KeepAsking := not IsValidDir();
  end;
end;
