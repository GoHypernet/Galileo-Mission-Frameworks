# HECRAS
Industry: H&H

Target OS: Windows

License: Closed source, free to user

Website: https://www.hec.usace.army.mil/software/hec-ras/

Notes: This branch builds a windows container for running the HECRAS simulator 
for versions 5.0.7 and 5.0.5. 

It installs python 3.7 and the entrypoint is the runras.bat file which
checks some environment variables before calling runras.py. 
