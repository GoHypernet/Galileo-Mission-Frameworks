FROM microsoft/dotnet-framework

# Install python 3.7.1 64bit for running scripts against COM object
ADD .\\python-3.7.1-amd64.exe .
RUN c:\python-3.7.1-amd64.exe /quiet /install && del c:\python-3.7.1-amd64.exe

# Install pywin32 and numpy modules
RUN py -m pip install --upgrade pip && py -m pip install pywin32 && py -m pip install numpy

# Install Visual C++ runtimes 
COPY .\\Visual-C-Runtimes-All-in-One.zip C:\\vc_runtimes.zip
COPY .\\extractRuntimes.py C:\\extractRuntimes.py
RUN py extractRuntimes.py
RUN C:\\vc_runtimes\install_all.bat && del C:\vc_runtimes.zip
#RUN rmdir C:\vc_runtimes /s

# Install oledlg.dll to mimic gui utilities
COPY .\\oledlg.dll C:\\Windows\\SysWOW64\\oledlg.dll

# Copy the HECRAS installer
COPY .\\HEC-RAS_507_Without_Examples_Setup.exe C:\\HECRASInstall.exe

# install HECRAS and remove installer
RUN .\\HECRASInstall.exe /s /x /b"C:\hecras" /v"/qn"
RUN msiexec /log logfile.txt /i "C:\\hecras\\HEC-RAS 5.0.7.msi" /quiet && del C:\HECRASInstall.exe

# Register the executable
COPY .\\GetSystemStatistic.py C:\\GetSystemStatistic.py

# copy an example directory 
COPY .\\Bald_Eagle_Creek C:\\data