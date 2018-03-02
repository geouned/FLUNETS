# FLUNETS
% -------------------------------------------------------------------------------------------------
## FLUNETS - Tool definition

FLUNETS is a tool to extract and order fluvial network from a Digital Elevation Model (DEM).
The aim is to provide a continuous fluvial network, where the value of 
each river remains the same from the confluence upstream to the headwater. 
FLUNETS internally uses TopoToolbox functions (DOI: 10.5194/esurf-2-1-2014) to calculate 
flow-related matrices derived from the DEM.

% -------------------------------------------------------------------------------------------------
## Contact details

For more information on FLUNETS, please contact:

Candela Pastor
cpastor [at] pas.uned.es

% -------------------------------------------------------------------------------------------------
## Requirements

FLUNETS requires Matlab 2011b or higher version and the Image Processing Toolbox.

% -------------------------------------------------------------------------------------------------
## Getting started

FLUNETS consists of 6 functions. These functions need to be on the search path of Matlab.  
FLUNETS_main.m adds the directories required to execute FLUNETS successfully. 

Do not change the directory structure.
