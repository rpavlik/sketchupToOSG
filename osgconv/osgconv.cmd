set OSG_LIBRARY_PATH=%~dp0
cd /d "%~dp2"
set INFILE=%~nx1
set OUTFILE=%~nx2
"%OSG_LIBRARY_PATH%\osgconv.exe" --use-world-frame -O OutputRelativeTextures "%INFILE%" "%OUTFILE%" %3 %4 %5 %6 %7 %8 %9