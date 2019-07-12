import os
import shutil
from PickledObject import PickledObject
from pathlib import Path

print("... Cleaning up results ...")

# find the pickled object that contains the file to use for the cutoff time
starttime_path = os.path.join(os.getcwd(),"starttime.bin")
runstarttime = PickledObject(starttime_path, dict)

# retrieve the name of the beacon file
beaconfile = None
for k in runstarttime.obj.keys():
    beaconfile = Path(k)

# query the cutoff time from the beaconfile
cutofftime = beaconfile.stat().st_mtime
print("cutofftime is ",cutofftime)

# if the file make time is before or equal to the cutoff, delete it
for file in Path(os.getcwd()).iterdir():
    if file.stat().st_mtime <= cutofftime:
        if file.is_dir():
            # directories should be removed entirely
            shutil.rmtree(file)
        else:
            # files should be removed individually
            file.unlink()