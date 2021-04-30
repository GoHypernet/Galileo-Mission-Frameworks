# get the caddy executable in stage 1
FROM caddy AS caddy-build

# build the IDE in stage 2
FROM mcr.microsoft.com/windows:1809 AS ide

# get app specs and set working directory
COPY package.json "C:\Users\Public\theia\package.json"
WORKDIR /Users/Public/theia

# install scoop package manager, node, yarn, git and python
RUN powershell.exe -NoLogo -Command "Set-ExecutionPolicy RemoteSigned -scope CurrentUser; iwr -UseBasicParsing 'https://get.scoop.sh' | iex;"
RUN scoop install nvm; nvm install 12.14.1; nvm use 12.14.1; scoop install yarn git python

# Copy our Install script.
COPY Install.cmd "C:\TEMP\Install.cmd"

# Use the latest release channel. For more control, specify the location of an internal layout.
ARG CHANNEL_URL=https://aka.ms/vs/16/release/channel
ADD ${CHANNEL_URL} "C:\TEMP\VisualStudio.chman"

# Install Build Tools with C++ compiler
ADD https://aka.ms/vs/16/release/vs_buildtools.exe "C:\TEMP\vs_buildtools.exe"
RUN C:\TEMP\install.cmd C:\TEMP\vs_buildtools.exe \
    --quiet --wait --norestart --nocache \
    --installPath C:\VisualStudio \
    --channelUri C:\TEMP\VisualStudio.chman \
    --installChannelUri C:\TEMP\VisualStudio.chman \
    --add Microsoft.VisualStudio.Workload.VCTools;includeRecommended \
    --add Microsoft.Component.MSBuild \
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

RUN yarn --pure-lockfile
RUN yarn theia build
RUN yarn theia download:plugins

# build the tuflow runtime image
FROM mcr.microsoft.com/windows:1809

# copy all Tuflow bundles into images
COPY ./exe /exe

# unzip and remove .zip files
RUN powershell -Command "Get-ChildItem '/exe/.' -Filter *.zip | Expand-Archive -DestinationPath '/exe/.' -Force"
RUN powershell -Command "Get-ChildItem '/exe/.' -Filter *.zip | foreach ($_) {remove-item $_.fullname}"

# set Default executable paths to be the latest version
ENV EXE_iSP "C:\\exe\\2020-01-AA\\TUFLOW_iSP_w64.exe -nmb -nc"
ENV EXE_iDP "C:\\exe\\2020-01-AA\\TUFLOW_iDP_w64.exe -nmb -nc"

# set working directory to Public folder
WORKDIR /Users/Public/theia

RUN mkdir "C:\Users\Public\tuflow"

# add a runtime .bat files for batch and interactive modes
COPY run_tuflow.bat run_tuflow.bat
COPY run_ide.py run_ide.py
COPY Caddyfile "C:\Users\Public\caddy\Caddyfile"

# create some usefule batch files
RUN echo C:\Users\Public\caddy\caddy.exe run -adapter caddyfile -config C:\Users\Public\caddy\Caddyfile > run_caddy.bat
RUN echo node .\src-gen\backend\main.js C:\Users\Public\tuflow --hostname=0.0.0.0 > run_ide.bat

# install package manager 
ENV SCOOP "C:\scoop"
ENV SCOOP_HOME "C:\scoop\apps\scoop\current"

# install necessary runtime environments for ide
RUN powershell.exe -NoLogo -Command "Set-ExecutionPolicy RemoteSigned -scope CurrentUser; iwr -UseBasicParsing 'https://get.scoop.sh' | iex;"
RUN scoop install nvm; nvm install 12.14.1; nvm use 12.14.1; scoop install python

# get builds from stages 1 and 2
COPY --from=ide "C:\Users\Public\theia" "C:\Users\Public\theia"
COPY --from=caddy-build "C:\caddy.exe" "C:\Users\Public\caddy\caddy.exe"

# set login credentials and write them to text file
# uncomment these lines if testing locally
#ENV USERNAME "myuser"
#ENV PASSWORD "testpass2"
#RUN C:\\Users\\Public\\caddy\\caddy.exe hash-password -plaintext %PASSWORD% > "C:\Users\Public\caddy\hpassword.txt"

# set entrypoint for either batch or interactive mode
#ENTRYPOINT ["run_tuflow.bat"]
ENTRYPOINT ["python","run_ide.py"]
