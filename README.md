<p align="center">
  <img src="https://github.com/GoHypernet/Galileo-Mission-Frameworks/blob/pcswmm/pcswmm_logo.jfif" width="225">
</p>

# PCSWMM
## Overview

- **Industry**: Hydrology and Hydraulic Modeling

- **Target OS**: Windows

- **Source Code**: PCSWMM desktop application is closed source, the associated deployment script (given here) is open source. 

- **Website**: www.pcswmm.com

## Notes

This branch contains python scripts for the integration of [Galileo](https://hypernetlabs.io/galileo/) functions into the 
PCSWMM desktop application. The scripts deploy a [SWMM5](https://github.com/GoHypernet/Galileo-Mission-Frameworks/tree/epa-swmm) 
job to a remote instance, track its progress, download the results, and refresh the currently loaded model. 

## Installation

You must be running the latest version of the PCSWMM desktop application. Place galileo.py and run_form.py in the
`%AppData%\PCSWMM\Scripts` directory. Next, unzip the env-galileo folder (which is the Galileo SDK) and place it inside the PCSWMM Lib directory at 
`C:\Program Files (x86)\PCSWMM Professional 2D (x64)\Lib\`. You will then be able to execute them from the PCSWMM IronPython environment. 
