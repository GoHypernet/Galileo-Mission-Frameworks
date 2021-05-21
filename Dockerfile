FROM mcr.microsoft.com/windows:1809 AS runtimes

# Install Visual C++ runtimes 
COPY Visual-C-Runtimes-All-in-One.zip /vc_runtimes.zip
RUN mkdir vc_runtimes
RUN tar -xvf /vc_runtimes.zip -C /vc_runtimes

FROM mcr.microsoft.com/windows:1809

# install necessary runtime environments for ide
RUN powershell.exe -NoLogo -Command "Set-ExecutionPolicy RemoteSigned -scope CurrentUser; iwr -UseBasicParsing 'https://get.scoop.sh' | iex;"
RUN scoop install python

# Install pywin32 and numpy modules
RUN python -m pip install in_place

# Install Visual C++ runtimes 
COPY --from=runtimes /vc_runtimes /vc_runtimes
RUN /vc_runtimes/install_all.bat

# Get Flo2D executable
COPY ./flo2d /flo2d
COPY ./runflo.py /runflo.py

WORKDIR /Users/Public/flo2d
ENV GALILEO_RESULTS_DIR "C:\Users\Public\flo2d"

ENTRYPOINT ["python","/runflo.py"]
