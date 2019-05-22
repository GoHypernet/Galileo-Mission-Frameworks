import win32com.client, os, shutil

# Initiate the RAS Controller class
hec = win32com.client.Dispatch("RAS507.HECRASController")

# Hide the computation window
hec.Compute_HideComputationWindow()

# find the project file and plans
RASproject = ''
Plans = []
for file in os.listdir(os.getcwd()):
    extension = file.split(".")[-1]
    # detect project file
    if extension == 'prj':
        RASProject = os.path.join(os.getcwd(),file)
        print("found project file: ", RASProject)

    # detect plan files
    if extension != 'py' and extension != 'prj' and (extension[0] == 'p' or extension[0] == 'P'):
        f = open(file,'r')
        header = f.readline()
        f.close()
        if header.find("Plan Title*"):
            pname = header.split('=')[1].rstrip('\n')
            Plans.append(pname)
            print(file,pname)

#Open the project
hec.Project_Open(RASProject)
        
# to be populated: number and list of messages, blocking mode
NMsg,TabMsg,block = None,None,True

# computations of the current plan
for plan in Plans:
    print('Running Plan: ',plan)
    hec.Plan_SetCurrent(plan)

    output = hec.Compute_CurrentPlan(NMsg,TabMsg,block)
    print(output)
	
# create a new folder to hold the results
try:
    resFolder = os.path.join(os.getcwd(),r'results')
    if not os.path.isdir(resFolder):
        os.mkdir(resFolder)
    # detect results and move them to new folder	
    for file in os.listdir(os.getcwd()):
        extension = file.split(".")[-1]
        if extension == 'dss' or extension[0] == 'O' or extension == 'color_scales' or extension == 'txt':
            shutil.move(file,os.path.join(resFolder,file))
except OSError:
	print("Creation of directory %s failed" % resFolder)
        

hec.QuitRas()       # close  HEC-RAS
del hec             # delete HEC-RAS controller