@echo off
IF EXIST "%READ_ONLY_MODEL_PATH%" (
ECHO "Copying the project located at %READ_ONLY_MODEL_PATH%" && XCOPY "%READ_ONLY_MODEL_PATH%" "%FLO_BASE_DIR%\%FLO_EXPERIMENT%" /y /f /e /z /j
) ELSE (
ECHO "No library model specified, falling back to default behavior"
)
C:/flo2d/FLOPRO.exe
taskkill /F /IM FLOPRO*
XCOPY "%FLO_BASE_DIR%\%FLO_EXPERIMENT%" %OUTPUT_DIRECTORY% /f /z /j /s /i /y && RD /Q /S "%FLO_BASE_DIR%\%FLO_EXPERIMENT%"