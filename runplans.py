import h5py, os, sys, time, fnmatch, subprocess, shutil
from pathlib import WindowsPath

# start the HECRAS process
try:
    proc = subprocess.Popen("C:\project.bat")
except:
    print("Please make sure you have placed a project in C:\\Users\\Public")
    quit()

# directory where RAS is operating
working_dir = WindowsPath(os.path.join(os.environ["RAS_BASE_DIR"],os.environ["RAS_EXPERIMENT"])) 
working_dir = working_dir.parent / (working_dir.name + " [Test]")

experiment_dest = WindowsPath(os.path.join(os.environ["OUTPUT_DIRECTORY"],os.environ["RAS_EXPERIMENT"]))   # name of folder where results will be moved

output_file = ''     # Full path to temporary plan file output in the working directory
new_output_file = '' # location to copy temporary plan file data so as not to interfere with RAS
experiment = ''      # just the name of the temporary plan file output

last_time_stamp = '' # make empty string for last time step observed

# perform a while loop with proc.poll() == None and try to get time stamps while waiting for simulation 
while proc.poll() == None: # Poll returns null while process is running
    
    if not output_file: # once we find the working directory, don't look for it anymore
        time.sleep(5)
        try:
            # find the the temporary plan output file
            if os.path.isdir(working_dir):
                for file in os.listdir(working_dir):
                    if fnmatch.fnmatch(file,"*.p*.tmp.hdf"):
                        output_file = os.path.join(working_dir,file)
                        experiment = file
                        
                        # put the copy of the temporary hdf file in the output directory
                        new_output_file = os.path.join(os.environ["RAS_BASE_DIR"],experiment)
            else:
                continue
        except Exception as e:
            print("Running Simulation:",e)
            sys.stdout.flush()
            
    else:
        time.sleep(60)
        try:
            
            # check if the current temporary hdf file is bigger than the last copy
            try:
                if os.stat(output_file)[6] == os.stat(new_output_file)[6]: # if the files are the same size, skip the rest of the loop
                    continue
            except: # this block is triggered the first loop
                if os.path.isfile(output_file):
                    subprocess.check_output(f'copy "{output_file}" "{new_output_file}" /y',shell=True)
                    #shutil.copy(output_file,new_output_file) # make a copy so as not to interrupt HECRAS
                continue

            if os.path.isfile(output_file): # check to make sure its still a file
                subprocess.check_output(f'copy "{output_file}" "{new_output_file}" /y',shell=True)
                #shutil.copy(output_file,new_output_file) # make a copy so as not to interupt HECRAS

            try: # attempt to retrieve the latest time step
                fhandle = h5py.File(new_output_file,"r")
                time_stamp_path = "Results/Unsteady/Output/Output Blocks/Base Output/Unsteady Time Series/Time Date Stamp"
                    
                try:
                    ts = fhandle[time_stamp_path][-1]
                    if last_time_stamp != ts:
                        last_time_stamp = ts
                        print("Last Flushed Time Stamp: ", last_time_stamp)
                        sys.stdout.flush()
                except:
                    ts = "Time Stamp data unavailable"
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