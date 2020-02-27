@echo off
C:\Users\ContainerAdministrator\AppData\Local\Programs\Python\Python37\python.exe C:\GetSystemStatistic.py
C:\Windows\System32\reg.exe import C:\ras07reg.reg
C:\Windows\System32\reg.exe import C:\ras05reg.reg
rem C:\Windows\System32\reg.exe import C:\ras03reg.reg
IF EXIST "%READ_ONLY_MODEL_PATH%" (
ECHO "Copying the project located at %READ_ONLY_MODEL_PATH%" && XCOPY "%READ_ONLY_MODEL_PATH%" "%RAS_BASE_DIR%\%RAS_EXPERIMENT%" /y /f /e /z /j
) ELSE (
ECHO "No library model specified, falling back to default behavior"
)
rem C:\rclone.exe sync -v %STORAGE%\. %RAS_BASE_DIR%
C:\Users\ContainerAdministrator\AppData\Local\Programs\Python\Python37\python.exe C:\runras.py
rem C:\rclone.exe move -v %OUTPUT_DIRECTORY% %STORAGE%