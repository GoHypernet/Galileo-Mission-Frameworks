The software will install to c:\Program Files (x86).  FLO-2D Engine is 64-Bit but our GUI is a 32 bit program so it forces the install here.  You probably only need these files to run a test.
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\hdf5dllx64.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\libiomp5md.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\systemflP.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\szlibdll.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\szlibdll32.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\VC2005-CON.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\xmdf1.9dll.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\xmdf1.9dllx64.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\xmdf99.99dllx64.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\zdll.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\zdllx64.dll"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\FLOPRO.exe"
"C:\Program Files (x86)\FLO-2D PRO\Run for Project Folder\hdf5dll.dll"
 

You can set up any of the example projects to run.  I recommend:
"C:\Users\Public\Documents\FLO-2D PRO Documentation\Example Projects\CA Aqueduct" - channel
"C:\Users\Public\Documents\FLO-2D PRO Documentation\Example Projects\Diamond" – overland only
"C:\Users\Public\Documents\FLO-2D PRO Documentation\Example Projects\Goat" – urban with streets, channel, levee
"C:\Users\Public\Documents\FLO-2D PRO Documentation\Example Projects\Storm Drain" – urban with storm drain
"C:\Users\Public\Documents\FLO-2D PRO Documentation\Example Projects\Urban Project Example" urban with channels, buildings, levee, culverts
"C:\Users\Public\Documents\FLO-2D PRO Documentation\Example Projects\Barn" – mudflow
 

For any of these, you need to set the display mode switch to 1 = Batch mode in Cont.dat.  This is the 3rd variable on line 1.  Batch mode is silent and does not require any action.
 

The engine will run if it is in the project folder or you can call it from the batch code.