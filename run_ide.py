import os, sys, time, shutil, subprocess
from pathlib import WindowsPath

# read the hashed password
with open(WindowsPath('/Users/Public/caddy/hpassword.txt'), 'r') as f:
    hpass = f.read()

# create the basic authentication file
basic_auth_contents = 'basicauth /* {\n    ' + os.environ['USERNAME'] + ' ' + hpass + '\n}'
with open(WindowsPath('/Users/Public/caddy/hashpass.txt'), 'w') as f:
    f.write(basic_auth_contents)

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