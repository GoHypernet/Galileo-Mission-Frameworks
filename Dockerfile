FROM mcr.microsoft.com/windows:1809
COPY exe/ /exe
ENV EXE_iSP "C:\\exe\\2018-03-AC\\TUFLOW_iSP_w64.exe"
ENV EXE_iDP "C:\\exe\\2018-03-AC\\TUFLOW_iDP_w64.exe"
WORKDIR /Users/Public/tuflow
COPY run_tuflow.bat run_tuflow.bat
USER ContainerUser
ENTRYPOINT ["run_tuflow.bat"]