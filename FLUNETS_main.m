% #########################################################################
% #########################################################################
% Description 
% 
%     FLUNETS provides ordered channel networks extracted from a DEM input.
%     Multiple input parameters are available in order to extract a
%     customized channel network. 
%	  FLUNETS uses some functions from TopoToolbox  
%	  (DOI:10.5194/esurf-2-1-2014) and requires MATLAB 2011b version and the Image 
%	  Processing Toolbox for some of its functions. TopoToolbox terrain analysis 
%	  toolset is available for download on Wolfgang Schwanghart website, where you
%	  can find a direct download link from Github
%	  (https://github.com/wschwanghart/topotoolbox).
%
% 
%     The sorting hierarchies can be either Hack or Horton.
% 
%     In Hack hierarchy, the main stream is designated as order 1 and 
%     smaller tributary streams are designated with increasingly higher 
%     orders, from the stream confluence upstream to the headwaters. When 
%     a parent channel of order n meets a pour point, ascribes order n + 1 
%     to the joining tributary.
% 
%     In Horton hierarchy (in the inverse of Hack hierarchy),
%     it is considered that the main stream is the one with the highest
%     order and that unbranched fingertip tributaries should be 
%     designated by the same ordinal, fingertip tributaries are designated 
%     as order 1. Tributaries of second order receive only tributaries of 
%     first order, third order tributaries receive tributaries of second 
%     order but may also receive first order tributaries, and so on. Needs 
%     to compute Strahler first. 
%
%
% Parameters:
% 
%     Mandatory parameters:
% 
%     Digital Elevation Model: An ESRI ASCII or TIF/GeoTIFF file. 
%                               
%     Sorting Method: The sorting hierarchy. Values: 'hack' or 'horton'.
%     
%     Attribute of hierarchy: Hierarchy attribute defines the hierarchy of a 
%                          segment over another when two or more segments 
%                          converge in a confluence. Values: 'accumulation' or 
%                          'distance'.
% 
%     Optional parameters:
% 
%     If these parameters are left empty, a default value for each 
%     parameter will be set. 
% 
%     Max. tributary order: Is the '-ith' order up to which the network 
%     will be sorted. Only tributaries of equal or lower order to 
%     the value set will be sorted. If left empty, all tributaries 
%     will be sorted. Write an integer, else leave empty.
% 
%     Min. drainage area: Is the minimum drainage area of a channel to 
%     be sorted. Only channels with equal or higher drainage area than the 
%     value set will be sorted. If left empty, the default value 
%     will be 10^-4 of the total DEM watershed area in square
%     meters. Write a number, can be float, double or integer, else leave 
%	  empty.
% 
%     Max. base: Is the limitant height of an outlet point to be sorted.
%     If an outlet is located at a lower height to the value set,
%     it will be considered. Write a number, can be float, double or integer,
%	  else leave empty.
% 
%     Internal fluvial files: This parameter provides the matrices generated 
%     internally with Topotoolbox functions' (flow direction, flow
%     accumulation, flow distance and Strahler matrices (for Horton)).
%     Is string type. If you want the internal matrices write 'yes', else 
%     leave empty.
% 
%     Pour points file: This parameter provides the pour point matrix.
%     The pour points are the first point in each tributary, neighbours 
%     to the confluence with the main channel. Is string type. If you want the 
%	  pour points matrix write 'yes', else leave empty.
% 
%     File extension: The output raster extension, write 'tif' for a 
%     Tif/GeoTiff file or 'ascii' for an ASCII file.
%     
%     
%
%
%  Output files:
% 
%     Output files: A raster file and a .csv  file.
%
%     Both files can be drawn directly in ArcMap.
%     These file will be located inside 'outputs/channel_network/' and 'outputs/csv/'
%     folders respectively.
%
%
% Meaning for the .csv columns:
% 
%	Field1: 'x', is the x coordinate (in a projected system).
%	Field2: 'y', is the y coordinate (in a projected system).
%	Field3: 'z', is the elevation.
%	Field4: 'riv_value', is the river value (Hack or Horton order).
%	Field5: 'acc_value', is the accumulation value upstream direction.
%	Field6: 'area_value', is the drainage area in square meters.
%	Field7: 'id_value', the id number of each river (unique).
%	Field8: 'dis_value', is the distance upstream direction.
%   Field9: 'pourpoint_value', the pour points location.
%   Field10: 'out_value', the outlets location.

% #########################################################################
% #########################################################################

% paths to be added to MATLAB environment
% set the paths where the FLUNETS functions and the TopoToolbox are located
% -------------------------------------------------------------------------
addpath ..path\stream_ordering_tools %add the path where FLUNETS functions are stored.
addpath ..path\topotoolbox           %add the path where Topotoolbox functions are stored.

% -------------------------------------------------------------------------
inputs = inputdlg({'Sorting Method','Hierarchy Attribute','Max. tributary order (optional)','Min. drainage area (optional)','Max. base (optional)','Calculate Internal fluvial files: (yes/no) (optional)','Calculate Pour Points: (yes/no) (optional)','Output File extension: TIF or ASC (optional)'},'Fill the inputs', [1,60], { 'hack' 'accumulation' '' '' '' '' '' 'tif'}, 'on');
flunet_chan_res =  build_streams_map(inputs) ; % calls build_streams_map







