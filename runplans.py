import os
from PickledObject import PickledObject
from pathlib import Path

# find the project file
RASproject = ''
for file in os.listdir(os.getcwd()):
    extension = file.split(".")[-1]
    # detect project file
    if extension == 'prj':
        f = open(file,'r')
        header = f.readline()
        f.close()
        # check if its arcGIS or HEC-RAS
        if header.find("Proj Title") != -1:
            RASProject = str(file)
            #RASProject = os.path.join(os.getcwd(),file)
            print("found project file: ", RASProject)

print("Project file detected:",RASProject)

# find the last file in the directory alphabetically for use in determining cutoff time
starttime_path = os.path.join(os.getcwd(),"starttime.bin")
runstarttime = PickledObject(starttime_path, dict)

file, mtime = None, None
for file in Path(os.getcwd()).iterdir():
    if (file.suffix not in {".old",".py",".bat"}) and (file != "__pycache__"): 
        mtime = file.stat().st_mtime

print("beacon file is:",file)

runstarttime.obj[str(file)] = mtime
runstarttime.dump()

# form the contents of the project.bat file
rasruncontents = f'"C:\\Program Files (x86)\\HEC\\HEC-RAS\\5.0.7\\Ras.exe" -test "C:\\data [Test]\\{RASProject}"'

# open and write the project.bat file
rasrunfile = os.path.join(os.getcwd(),"project.bat")
f = open(rasrunfile,'w')
f.write(rasruncontents)
f.close()