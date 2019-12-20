@echo off
py C:\GetSystemStatistic.py
C:\Windows\System32\reg.exe import C:\ras07reg.reg
rem C:\Windows\System32\reg.exe import C:\ras05reg.reg
rem C:\Windows\System32\reg.exe import C:\ras03reg.reg
IF EXIST "%READ_ONLY_MODEL_PATH%" (
ECHO "Copying the project located at %READ_ONLY_MODEL_PATH%" && XCOPY "%READ_ONLY_MODEL_PATH%" "%RAS_BASE_DIR%\%RAS_EXPERIMENT%" /y /f /e /z /j
) ELSE (
ECHO "No library model specified, falling back to default behavior"
)
py "C:\runras.py