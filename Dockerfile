FROM mcr.microsoft.com/windows:1809

# Install python 3.7.1 64bit
COPY python-3.7.1-amd64.exe .
RUN c:\python-3.7.1-amd64.exe /quiet /install 
RUN del c:\python-3.7.1-amd64.exe

# Install pywin32 and numpy modules
RUN py -m pip install --upgrade pip  && py -m pip install in_place

# Install Visual C++ runtimes 
COPY .\\Visual-C-Runtimes-All-in-One.zip C:\\vc_runtimes.zip
COPY .\\extractRuntimes.py C:\\extractRuntimes.py
RUN py extractRuntimes.py
RUN C:\\vc_runtimes\install_all.bat && del C:\vc_runtimes.zip && del C:\extractRuntimes.py
RUN rd /S /Q C:\vc_runtimes

COPY ./flo2d /flo2d
COPY ./runflo.bat /runflo.bat
#COPY ./runflo.py /runflo.py

WORKDIR /Users/Public/flo2d

ENV FLO_BASE_DIR="C:\Users\Public\flo2d"
ENV FLO_EXPERIMENT="."
ENV OUTPUT_DIRECTORY="C:\Users\Public\Output"

ENTRYPOINT ["/runflo.bat"]
