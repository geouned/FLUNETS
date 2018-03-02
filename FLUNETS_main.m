% Description 
% 
%     FLUNETS provides ordered channel networks extracted from a DEM input.
%     Multiple input parameters are available in order to extract a
%     customized channel network. 
% 
%     The sorting hierarchies can be either Hack or Horton.
% 
%     In Hack hierarchy, the main stream is designated as order 1 and 
%     smaller tributary streams are designated with increasingly higher 
%     orders, from the stream confluence upstream to the headwaters. When 
%     a parent channel of order n meets a junction, ascribes order n + 1 
%     to the joining tributary.
% 
%     In Horton hierarchy (in the inverse of Hack hierarchy),
%     it is considered that the main stream is the one with the highest
%     order and that unbranched fingertip tributaries should be 
%     designated by the same ordinal, fingertip tributaries are designated 
%     as order 1. Tributaries of second order receive only tributaries of 
%     first order, third order tributaries receive tributaries of second 
%     order but may also receive first order tributaries, and so on. Needs 
%     to compute Strahler first. The stream order will be the Strahler 
%     order at the pour point.


% Parameters:
% 
%     Mandatory parameters:
% 
%     dem_namefile: An ASCII DEM file written with the extension ('.asc).
%     The DEM file should be located in the 'inputs/' folder.
%     
%     sorting_type: The sorting hierarchy. Type 'hack' or 'horton'.
%     
%     hierarchy_attribute: Hierarchy attribute defines the hierarchy of a 
%                          segment over another when two or more segments 
%                          converge in a confluence. Type 'accumulation' or 
%                          'distance'.
% 
%     Optional parameters:
% 
%     If these parameters are left empty, a default value for each 
%     parameter will be set. 
% 
%     max_trib_order: Is the '-ith' order up to which the network 
%     will be sorted. Only tributaries of equal or lower order to 
%     the value set will be sorted. If left empty, all tributaries 
%     will be sorted. Type an integer, else leave max_trib_order = ''.
% 
%     min_drainage_area: Is the minimum drainage area of a channel to 
%     be sorted. Only channels with equal or higher drainage area than the 
%     value set will be sorted. If left empty, the default value 
%     will be 10^-4 of the total DEM watershed area in square
%     meters. Type an area (as integer), else leave min_drainage_area = ''.
% 
%     maxbase: Is the limitant height of an outlet point to be sorted.
%     If an outlet is located at a lower height to the value set,
%     it will not be considered. Type an integer, else leave maxbase = ''.
% 
%     internal_matrices: This parameter provides the matrices generated 
%     internally with Topotoolbox functions' (flow direction, flow
%     accumulation, flow distance and Strahler matrices (for Horton)).
%     If you want the internal matrices type 'yes', else leave 
%     intern_matrices = ''.
% 
%     junctions_points: This parameter provides the pour point matrix.
%     The pour points are the first point in each tributary, neighbours 
%     to the confluence with the main channel. If you want the pour points 
%     matrix type 'yes', else leave junctions_points = ''.
% 
%     output_name: The name for the resultant channel network in
%     ASCII format. Has to be written without the extension '.asc'. 
%     If no name is given, the resultant name will
%     be built by adding to the DEM name the values set in the parameters
%     joined by an underscore. Type a name, else leave output_name = ''.



%  Output files:
% 
%     Output files: An ACII file 
%                   and a .csv  file.
%
%     Both files can be drawn directly in ArcMap.
%     These file will be located inside 'outputs/images' and 'outputs'
%     folders respectively.


% Meaning for the .csv columns:
% 
%	Field1: 'x', is the x coordinate (in a projected system).
%	Field2: 'y', is the y coordinate (in a projected system).
%	Field3: 'z', is the elevation.
%	Field4: 'value', is the river value (Hack or Horton order).
%	Field5: 'accumulation', is the accumulation value upstream direction.
%	Field6: 'area', is the drainage area in square meters.
%	Field7: 'id', the id number of each river (unique).
%	Field8: 'distance', is the distance upstream direction.




% paths to be added to MATLAB environment
% -------------------------------------------------------------------------
addpath stream_ordering_tools_prueba
addpath topotoolbox-master
addpath inputs
addpath outputs
addpath outputs/images

% declare global variables
% -------------------------------------------------------------------------
global sorting_type
global hierarchy_attribute
global max_trib_order
global min_drainage_area
global maxbase
global internal_matrices
global junctions_points
global output_name


% parameters
% -------------------------------------------------------------------------
% mandatory parameters
[dem_namefile, extension]     = strtok('arlanza.asc', '.');     
sorting_type                  = 'hack';                               
hierarchy_attribute           = 'accumulation';                       

% optional parameters
% -------------------------------------------------------------------------
max_trib_order                = '2';                             
min_drainage_area             = '';                     
maxbase                       = '';                              
internal_matrices             = '';                              
junctions_points              = '';
output_name                   = '';

% calls build_streams_map
% -------------------------------------------------------------------------
flunet_chan_res =  build_streams_map(dem_namefile,extension) ; 







