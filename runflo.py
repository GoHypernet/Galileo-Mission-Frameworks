import os, sys, time, subprocess, in_place
from pathlib import WindowsPath

print("Current dir:",os.getcwd())
sys.stdout.flush()

working_dir = os.getcwd()

# Set the model to run in headless batch mode by opening the CONT.DAT file and setting the 3 variable on the first line to 1 
contfile = working_dir / WindowsPath('CONT.DAT')
# loop over each line
with in_place.InPlace(contfile) as contdat:
    # but only edit the first line
    firstline = True
    for line in contdat:
        if firstline:
            counter = 0
            newline = ''
            for thing in line.split('  '):
                if thing:
                    counter += 1
                # find the 3rd variable on the header line
                if counter == 3:
                    # set it equal to one
                    thing = '1'
                    counter += 1
                if thing:
                    newline += thing + '  '
            # contruct the new header line
            line = newline
        # write the line back to the file
        contdat.write(newline)


# write a .bat file that for running FLO2D and moveing results around
try:
    flo2dexe = WindowsPath('C:/flo2d/FLOPRO.exe')
    # form the contents of the project.bat file, run the plan, then copy it to destination
    runcontents = f'cd {working_dir}'
    runcontents += f'\n{flo2dexe}'   
    runcontents += f'\n@echo off'
    runcontents += f'\nXCOPY "{working_dir}" "{experiment_dest}" /f /z /j /s /i /y && rd /Q /S "{working_dir}"'

    # open and write the project.bat file
    runfile = "C:\project.bat"
    f = open(runfile,'w')
    f.write(runcontents)
    f.close()
except Exception as e:
    print("Could not locate project file.")
    sys.stdout.flush()
    exit()

subprocess.Popen(f'cmd /C dir')

# start the FLOPRO process in the background
try:
    proc = subprocess.Popen("C:\project.bat")
except:
    print("Please make sure you have placed a project in C:\\Users\\Public")
    exit()

summary_file = working_dir / WindowsPath('SUMMARY.OUT') # Full path to temporary plan file output in the working directory

# perform a while loop with proc.poll() == None and tail the summary file
while proc.poll() == None: # Poll returns null while process is running
    print("top of loop")
    sys.stdout.flush()
    subprocess.Popen(f'cmd /C dir')
    if (not os.path.isfile(summary_file)) : 
        print("waiting for summary file")
        sys.stdout.flush()
        time.sleep(5)
    else :
        time.sleep(10)
        print("tailing summary")
        sys.stdout.flush()
        subprocess.run(f'cmd /C type {summary_file}')
        # tail the summary file            
    