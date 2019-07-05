import os

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

# form the contents of the project.bat file
rasruncontents = f'"C:\\Program Files (x86)\\HEC\\HEC-RAS\\5.0.7\\Ras.exe" -c "C:\\data\\{RASProject}"'

# open and write the project.bat file
rasrunfile = os.path.join(os.getcwd(),"project.bat")
f = open(rasrunfile,'w')
f.write(rasruncontents)
f.close()