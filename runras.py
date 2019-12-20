import h5py, os, sys, time, fnmatch, subprocess, shutil, datetime, psutil
from dateutil.parser import parse
from pathlib import WindowsPath

# the working directory must always be in the container filesystem
try:
    working_dir = WindowsPath(os.path.join(os.environ["RAS_BASE_DIR"],os.environ["RAS_EXPERIMENT"])) # directory where RAS is operating
    experiment_dest = WindowsPath(os.path.join(os.environ["OUTPUT_DIRECTORY"],os.environ["RAS_EXPERIMENT"]))   # name of folder where results will be moved
    scratch_path = WindowsPath(os.environ["SCRATCH"])
except:
    print("Error retrieving necessary environment variables")
    exit()

# ensure that we set a compatible RAS version
try:
    rasversion = os.environ["RAS_VERSION"]
except:
    rasversion = '5.0.7'

# this ensures we do not inadvertently delete the results
if working_dir == experiment_dest:
    print(f'Input directory: {working_dir}')
    print(f'Output directory: {experiment_dest}')
    print(f'Input and Output directories must be set to different paths, aborting')
    exit()
    
# find the project file and current plan
RASproject = ''
plan_number = ''
for file in os.listdir(working_dir):
    if file.endswith(".prj"):
        f = open(os.path.join(working_dir, file),'r')
        header = f.readline()
        if header.find("Proj Title") != -1:
            RASProject = str(os.path.join(working_dir, file))
            # now extract current plan
            current_plan = f.readline()
            plan_number = current_plan.split("=")[-1].rstrip()
        f.close()

# write a .bat file that for running RAS and moveing results around
try:
    print("Project file detected: ",RASProject)
    print("Current Plan Number: ",plan_number)
    sys.stdout.flush()

    # form the contents of the project.bat file, run the plan, then copy it to destination
    rasruncontents = f'"C:\\Program Files (x86)\\HEC\\HEC-RAS\\{rasversion}\\Ras.exe" -test={plan_number} "{RASProject}"'   
    rasruncontents += f'\n@echo off'
    #rasruncontents += f'\nXCOPY "{working_dir} [Test]" "{experiment_dest}" /f /z /j /s /i /y && rd /Q /S "{working_dir} [Test]"'
    rasruncontents += f'\nrd /Q /S "{working_dir}" && XCOPY "{working_dir} [Test]" "{experiment_dest}" /f /z /j /s /i /y && rd /Q /S "{working_dir} [Test]"'

    # open and write the project.bat file
    rasrunfile = "C:\project.bat"
    f = open(rasrunfile,'w')
    f.write(rasruncontents)
    f.close()
except Exception as e:
    print("Could not locate RAS project file.")
    sys.stdout.flush()
    exit()

# start the HECRAS process in the background
try:
    proc = subprocess.Popen("C:\project.bat")
except:
    print("Please make sure you have placed a project in C:\\Users\\Public")
    exit()

# directory where RAS is operating
working_dir = working_dir.parent / (working_dir.name + " [Test]")

output_file = ''     # Full path to temporary plan file output in the working directory
new_output_file = '' # location to copy temporary plan file data so as not to interfere with RAS
experiment = ''      # just the name of the temporary plan file output

time_stamp_path = "Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/Time Date Stamp"
information_path = "Plan Data/Plan Information"

last_time_stamp = '' # make empty string for last time step observed
final_time_stamp = None
initial_time_stamp = None
time_window = None
progress = None

RasUnsteady64 = None

# perform a while loop with proc.poll() == None and try to get time stamps while waiting for simulation to complete
while proc.poll() == None: # Poll returns null while process is running
    # once we find the .tmp.hdf file and the RasUnsteady64 PID, don't look for them anymore
    if (not output_file) or (not RasUnsteady64): 
        time.sleep(5)
        try:
            # find the the temporary plan output file
            if os.path.isdir(working_dir):
                for file in os.listdir(working_dir):
                    if fnmatch.fnmatch(file,"*.p*.tmp.hdf"):
                        output_file = os.path.join(working_dir,file)
                        experiment = file
                        
                        # put the copy of the temporary hdf file in the output directory
                        new_output_file = os.path.join(scratch_path,experiment)
                        
            # try to find the RasUnsteady64.exe process ID
            for task in psutil.process_iter():
                taskinfo = task.as_dict(attrs=['pid','name'])
                if taskinfo['name'] == "RasUnsteady64.exe":
                    RasUnsteady64 = taskinfo['pid']
            else:
                continue
        except Exception as e:
            print("Running Simulation:",e)
            sys.stdout.flush()
            
    else:
        for i in range(0,30):
            time.sleep(3)
            if (proc.poll() != None): # if proc.poll() returns something other than None, then it has exited, there is no need to continue the loop
                if os.path.isfile(new_output_file):
                    os.remove(new_output_file)
                print("Terminating progress monitoring loop")
                sys.stdout.flush()
                exit()
        try:
            
            # check if the current temporary hdf file is bigger than the last copy
            try:
                if os.stat(output_file)[6] == os.stat(new_output_file)[6]: # if the files are the same size, skip the rest of the loop
                    continue
            except: # this block is triggered the first loop
                if os.path.isfile(output_file):
                    # make a copy so as not to interrupt HECRAS
                    subprocess.check_output(f'copy "{output_file}" "{new_output_file}" /y',shell=True)
                continue

            if (progress and progress > 98) or (not os.path.isfile(output_file)) or (not psutil.pid_exists(RasUnsteady64)): # stop this loop if almost done
                continue

            if os.path.isfile(output_file): # check to make sure its still a file
                subprocess.check_output(f'copy "{output_file}" "{new_output_file}" /y',shell=True) # make a copy so as not to interupt HECRAS

            try: # attempt to retrieve the latest time step
                fhandle = h5py.File(new_output_file,"r")
                    
                try:
                    # the parse fuction formats the time stamp for us into a more readable string
                    ts = parse(fhandle[time_stamp_path][-1])
                    
                    # if we don't already know what the final time stamp is, try to read it
                    if not final_time_stamp:
                        final_time_stamp = parse(fhandle[information_path].attrs["Simulation End Time"])
                        
                    # if we don't already know what the initial time stamp is, try to read it
                    if not initial_time_stamp:
                        initial_time_stamp = parse(fhandle[information_path].attrs["Simulation Start Time"])
                        
                    # Calculate the physical duration of the simultation if we don't already know it
                    if not time_window and (final_time_stamp and initial_time_stamp):
                        time_window = final_time_stamp - initial_time_stamp
                        
                    # if the current time stamp is different than the last one we read, print to stdout
                    if last_time_stamp != ts:
                        last_time_stamp = ts
                        progress = (ts - initial_time_stamp)/time_window * 100
                        print("Last Flushed Time Stamp: ", last_time_stamp," - ","{:3.2f}".format(progress),"% complete")
                        sys.stdout.flush()
                except:
                    ts = "Simulation Running, Time stamp data unavailable"
                    if last_time_stamp != ts:
                        last_time_stamp = ts
                        print(last_time_stamp)
                        sys.stdout.flush()
                        
                del fhandle
            except Exception as e:
                print("Simulation Running, time stamp data not available: ", e)
                sys.stdout.flush()
                
        except Exception as e:
            print("Exception: ", e)
            sys.stdout.flush()

if os.path.isfile(new_output_file):
    os.remove(new_output_file)