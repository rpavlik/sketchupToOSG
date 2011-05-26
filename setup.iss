#define MyAppName "SketchUp to OpenSceneGraph Exporter Plugin"
#define MyAppVersion "1.3.1"
#define MyAppPublisher "Ryan Pavlik"
#define MyAppPublisherURL "http://academic.cleardefinition.com"
#define MyAppURL "http://github.com/rpavlik/sketchupToOSG"
#define OSGVersion "2.8.5"
#define OSGSOVersion "74"
#define OTSOVersion "11"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppID={{78E42E4F-021F-4E10-B1C2-09CA19487330}
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
OutputBaseFilename=setup-sketchupToOpenSceneGraphPlugin-{#MyAppVersion}
Compression=lzma/Max
SolidCompression=true
DirExistsWarning=no
AppendDefaultDirName=false
AlwaysShowDirOnReadyPage=true
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; Files created for this project
Source: "openscenegraph_exportviacollada.rb"; DestDir: "{app}"; Flags: ignoreversion
Source: README.txt; DestDir: {app}; Flags: ignoreversion; DestName: SketchupToOpenSceneGraph-README.txt; 
Source: "osgconv\fileutils.rb"; DestDir: "{app}\osgconv"; Flags: ignoreversion
Source: "osgconv\LICENSE_1_0.txt"; DestDir: "{app}\osgconv"; Flags: ignoreversion
Source: "osgconv\osgconv.cmd"; DestDir: "{app}\osgconv"; Flags: ignoreversion
Source: "osgconv\osgconv.rb"; DestDir: "{app}\osgconv"; Flags: ignoreversion
Source: "osgconv\osgviewer.cmd"; DestDir: "{app}\osgconv"; Flags: ignoreversion

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

function InitializeSetup(): Boolean;
var
  KeepAsking: Boolean;
begin
  Result := True;
  SketchUpPluginsDir := ExpandConstant('{pf32}\Google\Google SketchUp 8\Plugins\');
  KeepAsking := not DirExists(SketchUpPluginsDir) or not FileExists(SketchUpPluginsDir  + '\..\SketchUp.exe')
  while Result and KeepAsking do begin
    SketchUpPluginsDir := ExpandConstant('{pf32}\Google\Google SketchUp 8\Plugins\');
    Result := BrowseForFolder('Could not find the Google SketchUp 8 plugin directory: please select it',
      SketchUpPluginsDir, False);
    KeepAsking := not DirExists(SketchUpPluginsDir) or not FileExists(SketchUpPluginsDir + '\..\SketchUp.exe')
  end;
end;
