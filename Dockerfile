FROM mcr.microsoft.com/windows:1809

# copy all Tuflow bundles into images
COPY ./exe /exe

# unzip and remove .zip files
RUN powershell -Command "Get-ChildItem '/exe/.' -Filter *.zip | Expand-Archive -DestinationPath '/exe/.' -Force"
RUN powershell -Command "Get-ChildItem '/exe/.' -Filter *.zip | foreach ($_) {remove-item $_.fullname}"

# set Default executable paths to be the latest version
ENV EXE_iSP "C:\\exe\\TUFLOW.2020-01-AA\\TUFLOW_iSP_w64.exe -nmb -nc"
ENV EXE_iDP "C:\\exe\\TUFLOW.2020-01-AA\\TUFLOW_iDP_w64.exe -nmb -nc"

# set working directory to Public folder
WORKDIR /Users/Public/tuflow

# add a runtime .bat file
COPY run_tuflow.bat run_tuflow.bat

# set user account
USER ContainerUser

# set entrypoint
ENTRYPOINT ["run_tuflow.bat"]