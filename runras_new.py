import h5py, os, sys, time, fnmatch, subprocess, shutil, datetime, psutil, re
from dateutil.parser import parse
from pathlib import WindowsPath

# this is an auxilary function that checks for missing files
def check_file_paths(working_dir,project):
    project_rasmap = project.split('.')[0] + ".rasmap"
    if os.path.isfile(project_rasmap):
        rasmap = open(project_rasmap,'r')
        contents = rasmap.read()
        # this regex searches for all instances of Filename="..." where ... is any string
        hits = set(re.findall('Filename="(.*?)"',contents))
        for h in hits:
            if not os.path.isfile(os.path.join(working_dir,h)):
                print(f'Warning, {h} is referenced in {project_rasmap} but was not found')

# this is an auxilary function that checks if writes are committed to disk, returns a boolean
def check_hdf_flush(plan_file_name):
    if os.path.isfile(plan_file_name):
        plan_file = open(plan_file_name,'r')
        contents = plan_file.read()
        # this regex searches for all instances of Filename="..." where ... is any string
        hdfflush = bool(int(re.findall('HDF Flush=(.*)',contents)[0]))
        return hdfflush
    else:
        return None
            

# the working directory must always be in the container filesystem
try:
    working_dir = WindowsPath(os.path.join(os.environ["RAS_BASE_DIR"],os.environ["RAS_EXPERIMENT"])) # directory where RAS is operating
    experiment_dest = WindowsPath(os.path.join(os.environ["OUTPUT_DIRECTORY"],os.environ["RAS_EXPERIMENT"]))   # name of folder where results will be moved
    run_all_plans = bool(int(os.environ["RUN_ALL_PLANS"]))
    ras_plans = str(os.environ["RAS_PLANS"])
except Exception as e:
    print("Error retrieving necessary environment variables",e)
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
    
# if running current active plan, search for it

# find the project file and current plan
RASproject = ''
for file in os.listdir(working_dir):
    if file.endswith(".prj"):
        f = open(os.path.join(working_dir, file),'r')
        header = f.readline()
        if header.find("Proj Title") != -1:
            RASProject = str(os.path.join(working_dir, file))
            check_file_paths(working_dir,RASProject)
            if ras_plans == "active plan":
                # now extract current plan
                current_plan = f.readline()
                ras_plans = current_plan.split("=")[-1].rstrip()
        f.close()

# write a .bat file that for running RAS and moveing results around
try:
    print("Project file detected: ",RASProject)
    print("Plans to be executed: ",ras_plans)
    sys.stdout.flush()

    # form the contents of the project.bat file, run the plan, then copy it to destination
    if run_all_plans:
        rasruncontents = f'"C:\\Program Files (x86)\\HEC\\HEC-RAS\\{rasversion}\\Ras.exe" -test "{RASProject}"'   
    else:
        rasruncontents = f'"C:\\Program Files (x86)\\HEC\\HEC-RAS\\{rasversion}\\Ras.exe" -test={ras_plans} "{RASProject}"'

    rasruncontents += f'\n@echo off'
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

output_file = '' # Full path to temporary plan file output in the working directory
plan_file = ''   # name of running plan file
time_stamp_path = "Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/Time Date Stamp"
information_path = "Plan Data/Plan Information"

last_time_stamp = ''      # make empty string for last time step observed
results_size = None       # last known size of the output file
check_progress = False    # boolean that tells us whether or not to check the progress in the .hdf file
final_time_stamp = None   # last time stamp specified by the simulation
initial_time_stamp = None # t=0 for the simulation
time_window = None        # physical time window length
progress = None           # progress of the simulation

RasUnsteady64 = None      # process of the unsteady flow solver

# perform a while loop with proc.poll() == None and try to get time stamps while waiting for simulation to complete
while proc.poll() == None: # Poll returns null while process is running
    # once we find the .tmp.hdf file and the RasUnsteady64 PID, don't look for them anymore
    if (not os.path.isfile(output_file)) or (not RasUnsteady64): 
        time.sleep(5)
        try:
            # find the the temporary plan output file
            if os.path.isdir(working_dir):
                for file in os.listdir(working_dir):
                    if fnmatch.fnmatch(file,"*.p*.tmp.hdf"):
                        output_file = os.path.join(working_dir,file)                        
                        results_size = os.stat(output_file)[6]
                        plan_file = file.split(".")[0] + "." + file.split(".")[1]
                        check_progress = check_hdf_flush(os.path.join(working_dir,plan_file))
                        print("\n",f'Running {plan_file}')
                        sys.stdout.flush()
                        
            # try to find the RasUnsteady64.exe process ID
            for task in psutil.process_iter():
                taskinfo = task.as_dict(attrs=['pid','name'])
                if taskinfo['name'] == "RasUnsteady64.exe":
                    RasUnsteady64 = psutil.Process(taskinfo['pid'])
            else:
                continue
        except Exception as e:
            print("Running Simulation:",e)
            sys.stdout.flush()
            
    elif check_progress:
        for i in range(0,5):
            time.sleep(3)
            if (proc.poll() != None): # if proc.poll() returns something other than None, then it has exited, there is no need to continue the loop
                print("Terminating progress monitoring loop")
                sys.stdout.flush()
                exit()
        try:
            
            # stop this loop if already done
            if (not os.path.isfile(output_file)) or (not psutil.pid_exists(RasUnsteady64.pid)):
                continue

            # check if the current temporary hdf file is has changed size
            if os.stat(output_file)[6] == results_size: # if nothing has been written to disk, skip the rest of the loop
                continue
 
            results_size = os.stat(output_file)[6]

            # First pause the simulation engine, so as not to interupt the process
            RasUnsteady64.suspend()

            try: # attempt to retrieve the latest time step
                fhandle = h5py.File(output_file,"r")
                    
                try:
                    # the parse fuction formats the time stamp for us into a more readable string
                    ts = parse(fhandle[time_stamp_path][-1])
                    
                    # if we don't already know what the final time stamp is, try to read it
                    if not final_time_stamp:
                        final_time_stamp = parse(fhandle[information_path].attrs["Simulation End Time"])
                        
                    # if we don't already know what the initial time stamp is, try to read it
                    if not initial_time_stamp:
                        initial_time_stamp = parse(fhandle[information_path].attrs["Simulation Start Time"])

                    # Resume the simulation process 
                    RasUnsteady64.resume()
                        
                    # Calculate the physical duration of the simultation if we don't already know it
                    if not time_window and (final_time_stamp and initial_time_stamp):
                        time_window = final_time_stamp - initial_time_stamp
                        
                    # if the current time stamp is different than the last one we read, print to stdout
                    if last_time_stamp != ts:
                        last_time_stamp = ts
                        progress = (ts - initial_time_stamp)/time_window * 100
                        print(f'{plan_file} progress: ', last_time_stamp,' - ','{:3.2f}'.format(progress),'% complete')
                        sys.stdout.flush()
                except:
                    RasUnsteady64.resume()
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
