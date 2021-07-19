# get the caddy executable in stage 1
FROM caddy AS caddy-build

# build the IDE in stage 2
FROM hypernetlabs/galileo-ide:windows AS ide

# copy all Tuflow bundles into images
COPY ./exe /exe

# unzip and remove .zip files
RUN powershell -Command "Get-ChildItem '/exe/.' -Filter *.zip | Expand-Archive -DestinationPath '/exe/.' -Force"
RUN powershell -Command "Get-ChildItem '/exe/.' -Filter *.zip | foreach ($_) {remove-item $_.fullname}"

# build the tuflow runtime image
FROM mcr.microsoft.com/windows:1809

# install necessary runtime environments for ide
RUN powershell.exe -NoLogo -Command "Set-ExecutionPolicy RemoteSigned -scope CurrentUser; iwr -UseBasicParsing 'https://get.scoop.sh' | iex;"
RUN scoop install nvm; nvm install 12.14.1; nvm use 12.14.1; scoop install python

# get builds from stages 1 and 2
COPY --from=ide "C:\Users\Public\galileo-ide" "C:\Users\Public\galileo-ide"
COPY --from=ide /exe /exe
COPY --from=caddy-build "C:\caddy.exe" "C:\Users\Public\caddy\caddy.exe"

# get IDE widget configs
COPY .theia "C:\Users\ContainerAdministrator\.theia"
COPY .vscode "C:\Users\ContainerAdministrator\.vscode"

# set Default executable paths to be the latest version
ENV EXE_iSP "C:\\exe\\2020-01-AA\\TUFLOW_iSP_w64.exe -nmb -nc"
ENV EXE_iDP "C:\\exe\\2020-01-AA\\TUFLOW_iDP_w64.exe -nmb -nc"

# set working directory to Public folder
WORKDIR /Users/Public/galileo-ide

RUN mkdir "C:\Users\Public\tuflow"

# add a runtime .bat files for batch and interactive modes
COPY run_tuflow.bat /Users/Public/tuflow/run_tuflow.bat
COPY run_ide.py run_ide.py
COPY Caddyfile "C:\Users\Public\caddy\Caddyfile"

# create some usefule batch files
RUN echo C:\Users\Public\caddy\caddy.exe run -config C:\Users\Public\caddy\Caddyfile > run_caddy.bat
RUN echo node .\src-gen\backend\main.js C:\Users\Public\tuflow --hostname=0.0.0.0 > run_ide.bat

# install package manager 
ENV SCOOP "C:\scoop"
ENV SCOOP_HOME "C:\scoop\apps\scoop\current"

# set environment variable to look for the pulins in the correct directory
ENV THEIA_DEFAULT_PLUGINS "local-dir:c:\Users\Public\galileo-ide\plugins"

# set environment variable for result collection
ENV GALILEO_RESULTS_DIR "C:\Users\Public\tuflow"

# set login credentials and write them to text file
# uncomment these lines if testing locally
# ENV USERNAME "a"
# ENV PASSWORD "a"
# RUN C:\\Users\\Public\\caddy\\caddy.exe hash-password -plaintext %PASSWORD% > /Users/Public/caddy/hp.txt 

# ENTRYPOINT ["python","run_ide.py"]