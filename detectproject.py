import os, shutil, sys
from pathlib import WindowsPath

# the working directory must always be in the container filesystem
working_dir = WindowsPath(os.path.join(os.environ["RAS_BASE_DIR"],os.environ["RAS_EXPERIMENT"])) # directory where RAS is operating
experiment_dest = WindowsPath(os.path.join(os.environ["OUTPUT_DIRECTORY"],os.environ["RAS_EXPERIMENT"]))   # name of folder where results will be moved
try:
    rasversion = os.environ["RAS_VERSION"]
except:
    rasversion = '5.0.7'

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

try:
    print("Project file detected: ",RASProject)
    print("Current Plan Number: ",plan_number)
    sys.stdout.flush()

    # form the contents of the project.bat file, run the plan, then copy it to destination
    rasruncontents = f'"C:\\Program Files (x86)\\HEC\\HEC-RAS\\{rasversion}\\Ras.exe" -test={plan_number} "{RASProject}"'   
    rasruncontents += f'\nXCOPY "{working_dir} [Test]" "{experiment_dest}" /f /z /j /s /i /y && rd /Q /S "{working_dir}" && rd /Q /S "{working_dir} [Test]"'

    # open and write the project.bat file
    rasrunfile = "C:\project.bat"
    f = open(rasrunfile,'w')
    f.write(rasruncontents)
    f.close()
except Exception as e:
    print("Could not locate RAS project file.")
    sys.stdout.flush()