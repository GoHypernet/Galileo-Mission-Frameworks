import os, sys, time, shutil, subprocess, glob, zipfile
from pathlib import WindowsPath

try:
    model = None
    for file in glob.glob("*.zip"):
        print("Moving",file,"to workspace and decompressing")
        model = WindowsPath(file)
        zipfile.ZipFile(model).extractall('/Users/Public/tuflow/.')
        
    os.remove(WindowsPath('/Users/Public/tuflow/run_tuflow.bat'))
except Exception as e:
    print("Could not find and extract preloaded model")

try:
    # read the hashed password
    with open(WindowsPath('/Users/Public/caddy/hp.txt'), 'r') as f:
        hpass = f.read()

    # create the basic authentication file
    basic_auth_contents = 'basicauth /* {\n    ' + os.environ['USERNAME'] + ' ' + hpass + '\n}'
    with open(WindowsPath('/Users/Public/caddy/hashpass.txt'), 'w') as f:
        f.write(basic_auth_contents)
except Exception as e:
    print("Failed to generate credentials file")
    exit()

# start the caddy server in the background
try:
    caddy_proc = subprocess.Popen(WindowsPath('/Users/Public/galileo-ide/run_caddy.bat'))
except Exception as e:
    print("Problem starting Caddy Server:", e)
    exit()
    
# start the IDE process in the background
try:
    ide_proc = subprocess.Popen(WindowsPath('/Users/Public/galileo-ide/run_ide.bat'))
except Exception as e:
    print("Problem starting IDE process:", e)
    exit()

# perform a while loop with proc.poll() == None and tail the summary file
while (caddy_proc.poll() == None) and (ide_proc.poll() == None): # Poll returns null while process is running
    time.sleep(10)