import os, sys, time, shutil, subprocess, in_place, re
from pathlib import WindowsPath

print("Current dir:",os.getcwd())
sys.stdout.flush()

working_dir = os.getcwd()

# check for the existance of a license file, if it does not exist, exit, otherwise move it to windows/system32
systemflP = working_dir / WindowsPath('systemflP.dll')

if not systemflP.is_file():
    print("License file was not found, please place valid license in the parent folder")
    exit()
else: 
    shutil.move(systemflP,WindowsPath('/windows/system32') / systemflP.name)

# Set the model to run in headless batch mode by opening the CONT.DAT file and setting the 3 variable on the first line to 1 
contfile = working_dir / WindowsPath('CONT.DAT')

if not contfile.is_file():
    print("Could not locate CONT.DAT")
    exit()

with in_place.InPlace(contfile) as contdat:
    parts = contdat.readline().split()
    parts[2] = '1'
    first_line = ' '.join(parts) + '\n'
    contdat.write(first_line)
    for line in contdat.readlines():
        contdat.write(line)

# write a .bat file that for running FLO2D and moving results around
try:
    # first check if a FLOPRO.exe file was supplied
    flo2dexe = working_dir / WindowsPath('FLOPRO.exe')
    if not flo2dexe.is_file():
        flo2dexe = WindowsPath('C:/flo2d/FLOPRO.exe')
    else:
        print('Using FLOPRO executable supplied by user')
        
    # form the contents of the project.bat file, run the plan, then copy it to destination
    runcontents = f'\n{str(flo2dexe)}'
    runcontents += f'\n@echo off'

    # open and write the project.bat file
    runfile = "C:\project.bat"
    f = open(runfile,'w')
    f.write(runcontents)
    f.close()
except Exception as e:
    print("Could not locate project file.",e)
    sys.stdout.flush()
    exit()

# start the FLOPRO process in the background
try:
    proc = subprocess.Popen("C:\project.bat")
except:
    print("Please make sure you have placed a project in C:\\Users\\Public")
    exit()

summary_file = working_dir / WindowsPath('SUMMARY.OUT') # Full path to temporary plan file output in the working directory

old_stat = None
new_stat = None

last_len_stdout = 0
stdout = None

# perform a while loop with proc.poll() == None and tail the summary file
while proc.poll() == None: # Poll returns null while process is running
    sys.stdout.flush()
    if (not os.path.isfile(summary_file)) : 
        time.sleep(5)
    else :
        time.sleep(10)
        # don't print to screen if nothing has changed
        new_stat = os.stat(summary_file)[6]
        if new_stat == old_stat:
            continue
        old_stat = os.stat(summary_file)[6]

        sys.stdout.flush()
        cp = subprocess.run(f'cmd /C type {str(summary_file)}',capture_output=True)
        stdout = cp.stdout.decode('ascii')

        num_lines_to_print = len(stdout.split('\n')) - last_len_stdout
        
        for line in range(last_len_stdout,last_len_stdout+num_lines_to_print):
            print(stdout.split('\n')[line])
            sys.stdout.flush()
    
        last_len_stdout += num_lines_to_print - 1