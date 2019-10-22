#FROM microsoft/dotnet-framework:latest
#FROM hyperdyne/simulator:hecras507-14393-pre
FROM hyperdyne/simulator:hecras507-14393
#FROM hyperdyne/simulator:hecras507-17763-pre
#FROM hyperdyne/simulator:hecras507-17763

# Install python 3.7.1 64bit for running scripts against COM object
#COPY .\\python-3.7.1-amd64.exe .
#RUN c:\python-3.7.1-amd64.exe /quiet /install 
#RUN del c:\python-3.7.1-amd64.exe

# Install pywin32 and numpy modules
#RUN py -m pip install --upgrade pip && py -m pip install pywin32 && py -m pip install h5py

# Install Visual C++ runtimes 
#COPY .\\Visual-C-Runtimes-All-in-One.zip C:\\vc_runtimes.zip
#COPY .\\extractRuntimes.py C:\\extractRuntimes.py
#RUN py extractRuntimes.py
#RUN C:\\vc_runtimes\install_all.bat && del C:\vc_runtimes.zip && del extractRuntimes.py
#RUN del /Q C:\vc_runtimes\*
#RUN rd C:\vc_runtimes

# Install oledlg.dll to mimic gui utilities
#COPY .\\oledlg.dll C:\\Windows\\SysWOW64\\oledlg.dll
#COPY .\\srpapi.dll C:\\Windows\\SysWOW64\\srpapi.dll

# Copy the HECRAS installer
#COPY .\\HEC-RAS_507_Without_Examples_Setup.exe C:\\HECRASInstall.exe

# install HECRAS and remove installer
#RUN .\\HECRASInstall.exe /s /x /b"C:\hecras" /v"/qn"
#RUN msiexec /log logfile.txt /i "C:\\hecras\\HEC-RAS 5.0.7.msi" /quiet && del C:\HECRASInstall.exe

# Register the executable
#COPY .\\GetSystemStatistic.py C:\\GetSystemStatistic.py
#COPY ["runplans.py","\\runplans.py"]

#COPY ["detectproject.py","\\detectproject.py"]

#COPY ["runras.bat","\\runras.bat"]

#ENV RAS_BASE_DIR="C:\Users\Public\RAS"
ENV RAS_EXPERIMENT="."

#ENTRYPOINT ["C:\\runras.bat"]