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

# Copy the SRH2D executable
COPY .\\SRH-2D_V324_Distributiuon_20190620\\SRH-2D_Package\\Exec_bin C:\\srh2d_bin

COPY .\\runsrh2d.bat C:\\runsrh2d.bat

RUN mkdir C:\\Users\Public\srh2d

ENTRYPOINT ["C:\\runsrh2d.bat"]