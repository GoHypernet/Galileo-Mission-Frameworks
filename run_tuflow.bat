powershell -command "Expand-Archive -DestinationPath . -Force '%MODELARCHIVE%'"
powershell -command "Remove-Item -Path '%MODELARCHIVE%%'"
cd %RUNS_DIR%
".\%TUFLOW_BAT%"