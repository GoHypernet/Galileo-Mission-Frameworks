FROM mcr.microsoft.com/windows:1809

# transfer all installers into container
COPY swmm_installers/swmm51006_setup.exe /swmm51006_setup.exe
COPY swmm_installers/swmm51007_setup.exe /swmm51007_setup.exe
COPY swmm_installers/swmm51009_setup.exe /swmm51009_setup.exe
COPY swmm_installers/swmm51010_setup.exe /swmm51010_setup.exe
COPY swmm_installers/swmm51011_setup.exe /swmm51011_setup.exe
COPY swmm_installers/swmm51012_setup.exe /swmm51012_setup.exe
COPY swmm_installers/swmm51013_setup_1.exe /swmm51013_setup_1.exe
COPY swmm_installers/swmm51014_setup.exe /swmm51014_setup.exe

# run installers in silient mode
RUN swmm51006_setup.exe /s && del swmm51006_setup.exe && move "/Program Files (x86)/EPA SWMM 5.1" "\Program Files (x86)\EPA SWMM 5.1.006" && setx path "%path%;C:\\Program Files (x86)\\EPA SWMM 5.1.006\\"
RUN swmm51007_setup.exe /s && del swmm51007_setup.exe && move "/Program Files (x86)/EPA SWMM 5.1" "\Program Files (x86)\EPA SWMM 5.1.007" && setx path "%path%;C:\\Program Files (x86)\\EPA SWMM 5.1.007\\" 
RUN swmm51009_setup.exe /s && del swmm51009_setup.exe && move "/Program Files (x86)/EPA SWMM 5.1" "\Program Files (x86)\EPA SWMM 5.1.009" && setx path "%path%;C:\\Program Files (x86)\\EPA SWMM 5.1.009\\"
RUN swmm51010_setup.exe /s && del swmm51010_setup.exe && move "/Program Files (x86)/EPA SWMM 5.1" "\Program Files (x86)\EPA SWMM 5.1.010" && setx path "%path%;C:\\Program Files (x86)\\EPA SWMM 5.1.010\\"
RUN swmm51011_setup.exe /s && del swmm51011_setup.exe && move "/Program Files (x86)/EPA SWMM 5.1" "\Program Files (x86)\EPA SWMM 5.1.011" && setx path "%path%;C:\\Program Files (x86)\\EPA SWMM 5.1.011\\"
RUN swmm51012_setup.exe /s && del swmm51012_setup.exe && move "/Program Files (x86)/EPA SWMM 5.1" "\Program Files (x86)\EPA SWMM 5.1.012" && setx path "%path%;C:\\Program Files (x86)\\EPA SWMM 5.1.012\\"
RUN swmm51013_setup_1.exe /SP- /VERYSILENT && del swmm51013_setup_1.exe
RUN swmm51014_setup.exe /SP- /VERYSILENT && del swmm51014_setup.exe
RUN swmm51015_setup.exe /SP- /VERYSILENT && del swmm51015_setup.exe

# copy dlls into environment
COPY ["./swmm_dlls","C:/program files (x86)/swmm_dlls"]

# Install python 3.7.1 64bit for running scripts 
COPY python-3.7.7.exe .
RUN c:\python-3.7.7.exe /quiet /install 
RUN del c:\python-3.7.7.exe
RUN py -3-32 -m pip install --upgrade pip && py -3-32 -m pip install python-dateutil

# copy the run script into the container
COPY runswmm.py /runswmm.py

# set the default swmm engine to be the latest
ENV SWMM_VERSION=5.0.014

# set the working directory
RUN mkdir C:\Users\Public\SWMM
WORKDIR /Users/Public/SWMM

# must run python in 32-bit compatible mode
ENTRYPOINT ["py","-3-32","C:\\runswmm.py"]