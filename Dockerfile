FROM mcr.microsoft.com/windows:1809
COPY exe/ /exe
ENV EXE_iSP "C:\\exe\\2020-10-AA\\TUFLOW_iSP_w64.exe -nmb -nc"
ENV EXE_iDP "C:\\exe\\2020-10-AA\\TUFLOW_iDP_w64.exe -nmb -nc"
WORKDIR /Users/Public/tuflow
COPY run_tuflow.bat run_tuflow.bat
USER ContainerUser
ENTRYPOINT ["run_tuflow.bat"]