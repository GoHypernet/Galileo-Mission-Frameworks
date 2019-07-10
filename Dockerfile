FROM microsoft/dotnet-framework:latest

# Install python 3.7.1 64bit for running scripts against COM object
COPY .\\python-3.7.1-amd64.exe .
RUN c:\python-3.7.1-amd64.exe /quiet /install 
RUN del c:\python-3.7.1-amd64.exe

# Install pywin32 and numpy modules
RUN py -m pip install --upgrade pip && py -m pip install pywin32

# Install Visual C++ runtimes 
COPY .\\Visual-C-Runtimes-All-in-One.zip C:\\vc_runtimes.zip
COPY .\\extractRuntimes.py C:\\extractRuntimes.py
RUN py extractRuntimes.py
RUN C:\\vc_runtimes\install_all.bat && del C:\vc_runtimes.zip
#RUN del C:\vc_runtimes\* \f
#RUN rmdir C:\vc_runtimes 

# Install oledlg.dll to mimic gui utilities
COPY .\\oledlg.dll C:\\Windows\\SysWOW64\\oledlg.dll
COPY .\\srpapi.dll C:\\Windows\\SysWOW64\\srpapi.dll
COPY .\\KernelBase.dll.mui C:\\Windows\\SysWOW64\\en-US\\KernelBase.dll.mui
COPY .\\tzres.dll.mui C:\\Windows\\SysWOW64\\en-US\\tzres.dll.mui

# Copy the HECRAS installer
COPY .\\HEC-RAS_507_Without_Examples_Setup.exe C:\\HECRASInstall.exe

# install HECRAS and remove installer
RUN .\\HECRASInstall.exe /s /x /b"C:\hecras" /v"/qn"
RUN msiexec /log logfile.txt /i "C:\\hecras\\HEC-RAS 5.0.7.msi" /quiet && del C:\HECRASInstall.exe

# Register the executablepow
COPY [".\\GetSystemStatistic.py","C:\\GetSystemStatistic.py"]
COPY [".\\runplans.py".,"C:\\data [Test]\\runplans.py"]

COPY [".\\runras.bat","C:\\data [Test]\\runras.bat"]

#COPY .\\VB6.0-KB290887-X86.exe C:\\VB6.0-KB290887-X86.exe

ENTRYPOINT ["C:\\data [Test]\\runras.bat"]