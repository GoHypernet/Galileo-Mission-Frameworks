import os, six, ctypes, re, datetime, sys
from pathlib import Path
from dateutil.parser import parse

# Helper function to parse for time information
def get_date_time(inputfile,startend):
    if os.path.isfile(inputfile):
        filehandle = open(inputfile,'r')
        contents = filehandle.read()
        datestring = re.findall(f'{startend}_DATE(.*)',contents)[0].strip(' ')
        timestring = re.findall(f'{startend}_TIME(.*)',contents)[0].strip(' ')
        return parse(datestring+" "+timestring)
    else:
        return None

# what version of swmm engine to run 
swmm_version = os.environ["SWMMVERSION"]

swmm_lib_path = str(Path(f'C:\\Program Files (x86)\\EPA SWMM {swmm_version}\\swmm5.dll'))

# make sure version is supported
if not os.path.isfile(swmm_lib_path):
    print(f'SWMM DLL: {swmm_lib_path} not found. Version not supported.')
    exit()

print(f'\nSWMM Version {swmm_version}')

# get name of input file
swmm_name = str(os.environ["SWMMFILE"])
swmm_input = swmm_name + ".inp"
swmm_report = swmm_name + ".rpt"
swmm_output = swmm_name + ".out"

# make sure the file exists
if not os.path.isfile(swmm_input):
    print(f'Input file: {swmm_input} not found')
    exit()

# get size of the simulation window for computing simulation progress
startepoch = get_date_time(swmm_input,"START")
endepoch = get_date_time(swmm_input,"END")
simulation_window = endepoch - startepoch

swmm5 = ctypes.WinDLL(swmm_lib_path)

time1 = datetime.datetime.now()

# open the input file
errcode = swmm5.swmm_open(ctypes.c_char_p(six.b(swmm_input)), ctypes.c_char_p(six.b(swmm_report)), ctypes.c_char_p(six.b(swmm_output)))

# initialize the simulation
errcode = swmm5.swmm_start(ctypes.c_bool(True))

print("\n")

# simulation loop
percent_complete = 0
elapsed_time = ctypes.c_double()
swmm5.swmm_step(ctypes.byref(elapsed_time))
while elapsed_time.value > 0.0:
     swmm5.swmm_step(ctypes.byref(elapsed_time))
     dummy = int(datetime.timedelta(elapsed_time.value)/simulation_window *100)
     if dummy > percent_complete:
         percent_complete = dummy
         print(f'{swmm_name} progress:',' {:3.2f}'.format(percent_complete),'% complete')
         sys.stdout.flush()

# close the simulator
swmm5.swmm_end()
swmm5.swmm_close()
time2 = datetime.datetime.now()
print(f'\n... EPA-SWMM completed in: {time2-time1} seconds')