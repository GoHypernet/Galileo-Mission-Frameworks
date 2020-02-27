#FROM microsoft/dotnet-framework:latest
FROM hyperdyne/simulator:hecras
#FROM hyperdyne/simulator:hecras507-14393
#FROM hyperdyne/simulator:hecras507-17763-pre
#FROM hyperdyne/simulator:hecras-17763-test
#FROM mcr.microsoft.com/windows:1809

# Install python 3.7.6 64bit for running scripts against COM object
#COPY python-3.7.1-amd64.exe .
#RUN c:\python-3.7.1-amd64.exe /quiet /install 
#RUN del c:\python-3.7.1-amd64.exe

# Install pywin32 and numpy modules
#RUN py -m pip install --upgrade pip && py -m pip install pywin32 && py -m pip install h5py && py -m pip install python-dateutil && py -m pip install psutil

# Install Visual C++ runtimes 
#COPY Visual-C-Runtimes-All-in-One /vc_runtimes
#COPY .\\Visual-C-Runtimes-All-in-One.zip C:\\vc_runtimes.zip
#COPY .\\extractRuntimes.py C:\\extractRuntimes.py
#RUN py extractRuntimes.py
#RUN C:\\vc_runtimes\install_all.bat && del C:\vc_runtimes.zip && del C:\extractRuntimes.py
#RUN rd /S /Q C:\vc_runtimes

# Install oledlg.dll to mimic gui utilities
#COPY .\\oledlg.dll C:\\Windows\\SysWOW64\\oledlg.dll
#COPY .\\srpapi.dll C:\\Windows\\SysWOW64\\srpapi.dll

# Copy the HECRAS installer
#COPY .\\HEC-RAS_507_Without_Examples_Setup.exe C:\\HECRASInstall507.exe
#COPY .\\HEC-RAS_505_Without_Examples_Setup.exe C:\\HECRASInstall505.exe
#COPY .\\HEC-RAS_503_Without_Examples_Setup.exe C:\\HECRASInstall503.exe

# install HECRAS and remove installer
#RUN .\\HECRASInstall507.exe /s /x /b"C:\hecras507" /v"/qn"
#RUN .\\HECRASInstall505.exe /s /x /b"C:\hecras505" /v"/qn"
#RUN .\\HECRASInstall503.exe /s /x /b"C:\hecras503" /v"/qn"
#RUN msiexec /log C:\\hecras507\\logfile507.txt /i "C:\\hecras507\\HEC-RAS 5.0.7.msi" /quiet && del C:\HECRASInstall507.exe && rd /S /Q C:\\hecras507
#RUN msiexec /log C:\\hecras505\\logfile505.txt /i "C:\\hecras505\\HEC-RAS 5.0.5.msi" /quiet && del C:\HECRASInstall505.exe && rd /S /Q C:\\hecras505
#RUN msiexec /log C:\\hecras503\\logfile503.txt /i "C:\\hecras503\\HEC-RAS 5.0.3.msi" /quiet && del C:\HECRASInstall503.exe && rd /S /Q C:\\hecras503

# Register the executable
#COPY .\\GetSystemStatistic.py C:\\GetSystemStatistic.py

#COPY ["runras.bat","\\runras.bat"]

COPY ["runras_new.py","\\runras.py"]

#ENV OUTPUT_DIRECTORY="C:\Users\Public\Output"
#ENV RAS_BASE_DIR="C:\Users\Public\RAS"
#ENV RAS_EXPERIMENT="."
#ENV RAS_VERSION=5.0.7
#ARG SCRATCH
#ENV SCRATCH="C:\Users\Scratch"
#ENV RUN_ALL_PLANS=0
#ENV RAS_PLANS="active plan"

#RUN mkdir "C:\Users\Scratch"

# COPY /rclone.exe /rclone.exe
# COPY /rclone.conf /Users/ContainerAdministrator/.config/rclone/rclone.conf

#ENTRYPOINT ["C:\\runras.bat"]
#ENTRYPOINT ["cmd"]
