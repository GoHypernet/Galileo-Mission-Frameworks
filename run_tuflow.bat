powershell -command "Expand-Archive -DestinationPath . -Force '%MODELARCHIVE%'"
powershell -command "Remove-Item -Path '%MODELARCHIVE%%'"
cd %RUNS_DIR%
findstr /m "EXE_i" "%TUFLOW_BAT%"
if %errorlevel%==1 (
echo You did not reference EXE_iSP or EXE_iDP in your .bat script!
) else (
".\%TUFLOW_BAT%"
)