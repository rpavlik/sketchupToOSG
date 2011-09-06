cd %~dp0
set SKETCHUPDIR=%ProgramFiles(x86)%\Google\Google SketchUp 8
copy openscenegraph_exportviacollada.rb "%SKETCHUPDIR%\Plugins"
mkdir "%SKETCHUPDIR%\Plugins\osgconv"
copy osgconv\*.rb "%SKETCHUPDIR%\Plugins\osgconv"
"%SKETCHUPDIR%\SketchUp.exe"