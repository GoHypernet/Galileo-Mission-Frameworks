FROM mcr.microsoft.com/windows:1809
COPY exe/ /exe
COPY run_tuflow.bat /run_tuflow.bat
ENV DATA_DIRECTORY="C:\Users\Public\tuflow"
ENTRYPOINT ["/run_tuflow.bat"]