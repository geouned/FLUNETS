function matrices = build_streams_map(inputs) 

% declare global variables
% % -----------------------------------------------------------------------
global sorting_type
global hierarchy_attribute
global max_trib_order
global min_drainage_area
global maxbase
global internal_matrices
global pourpoints_points

global cell_size
global cell_area
global fdir_values
global fields
global id_river

% declare static variables, user must not change this!
% % -----------------------------------------------------------------------
% % mandatory parameters
sorting_type                  = lower(inputs{1,1});
hierarchy_attribute           = lower(inputs{2,1});

% optional parameters
% -------------------------------------------------------------------------
max_trib_order                = str2double(inputs{3,1});
min_drainage_area             = str2double(inputs{4,1});
maxbase                       = str2double(inputs{5,1});
internal_matrices             = inputs{6,1};
pourpoints_points             = inputs{7,1};
ext                           = lower(inputs{8,1});


max_trib_order                  = round(max_trib_order)+1; 
fdir_values                     = [2,1,128,4,100,64,8,16,32]; % directions of flowdir map
datetime                        = datestr(now,'_ddmmmmyyyy_HHMMSS');
und                             = '_';
id_river                        = 0; 

% Schwanghart TopoTools 2 functions
% padding: adds two rows and columns to the DEM.Z matrix with NaN values
% % -----------------------------------------------------------------------
DEM                             = GRIDobj(); 
DEM.Z                           = [NaN(size(DEM.Z,1)+4,2) [NaN(2,size(DEM.Z,2)); DEM.Z ; NaN(2,size(DEM.Z,2))] NaN(size(DEM.Z,1)+4,2)];
DEM.size                        = [DEM.size(1)+4,DEM.size(2)+4];
DEMf                            = fillsinks(DEM);
DEMf.Z(DEMf.Z<=0)               = NaN; %replace 0 and arcmap nan values with NaN


FD                              = FLOWobj(DEMf, 'preprocess', 'fill');
FA                              = flowacc(FD); 
S                               = STREAMobj(FD,flowacc(FD)>1);
FDIR                            = FLOWobj2GRIDobj(FD);

disp 'internal matrices created';

fields = [{'dem_fill'}, {'flowaccumulation'}, {'flowdir'}, {'flowdist'}, {'strahler'}, {'streams_matrix'}, {'id_matrix'}, {'dist_matrix'}, {'outlet_matrix'}, {'pourpoint_matrix'}];

matrices = struct;
for k = fields
    matrices.(k{1}) = NaN(size(DEMf.Z));
end

% declare var matrices
% % -----------------------------------------------------------------------
matrices.(fields{1})  = DEMf.Z; 
matrices.(fields{2})  = FA.Z;
matrices.(fields{3})  = FDIR.Z;
if strcmp(hierarchy_attribute ,'distance')
    DISTANCE                        = flowdistance(FD,S,'downstream');
    DISTANCE.Z(DISTANCE.Z<=0)       = NaN; %replace 0 and arcmap nan values with NaN
    matrices.(fields{4})            = DISTANCE.Z;
end

if strcmp(sorting_type ,'horton')
    STRAHLER                        = streamorder(FD,flowacc(FD)>1,'strahler');
    stra                            = double(STRAHLER.Z);
    stra(stra<=0)                   = NaN; %replace 0 and arcmap nan values with NaN  
    matrices.(fields{5})            = stra;
end

% declare static variables user must not change
% % -----------------------------------------------------------------------
cell_size                       = DEM.cellsize;
cell_area                       = power(cell_size,2); % in square meters

% declare default values for optional parameters
% % -----------------------------------------------------------------------
if isnan(min_drainage_area)         
    s=sign(DEM.Z); % signs DEM.Z
    ipositif=sum(s(:)==1);% computes positive elements
    min_drainage_area = ipositif * cell_area * 0.0001 ; % min area to be a stream
end

%  find outlets
% % -----------------------------------------------------------------------
if ~isnan(maxbase)
    outlet                =S.IXgrid(S.distance==0);
    outlet_z              =outlet(DEM.Z(outlet)<maxbase);
else
    outlet_z              =S.IXgrid(S.distance==0);
end

for a = 1:numel(outlet_z)
    matrices.(fields{9})(outlet_z(a)) = 1;
end

clear S;
clear FD;

% loops through each outlet to extract and order each channel network
% % -----------------------------------------------------------------------
for item = 1:numel(outlet_z)    
    xy_pourpoint_copy = outlet_z(item);    
    xy_area = matrices.(fields{2})(xy_pourpoint_copy)*cell_area;       
    if xy_area >= min_drainage_area    
        switch sorting_type
            case 'hack'
                order_pourpoint_copy     = '';
            case 'horton'
                order_pourpoint_copy     = matrices.(fields{5})(xy_pourpoint_copy);
        end

        % calls build_channelnetwork function
        % % -------------------------------------------------------------------
        [matrices] = build_channel_network( xy_pourpoint_copy, order_pourpoint_copy, matrices);

    end
end

% removes the padding 
% % -----------------------------------------------------------------------
for m = 1:10
    matrices.(fields{m}) = matrices.(fields{m})(3:size(matrices.(fields{m}),1)-2,3:size(matrices.(fields{m}),2)-2);
end

% resize and turn matrices to GRIDobjs
% % -----------------------------------------------------------------------
DEMf.Z                          = matrices.(fields{1});
DEMf.size                       = [DEMf.size(1)-4,DEMf.size(2)-4];

FDIR.Z                          = matrices.(fields{3});
FDIR.size                       = [FDIR.size(1)-4,FDIR.size(2)-4];

FA.Z                            = matrices.(fields{2});
FA.size                         = [FA.size(1)-4,FA.size(2)-4];

if strcmp(hierarchy_attribute ,'distance')
    DISTANCE.Z                  = matrices.(fields{4});
    DISTANCE.size               = [DISTANCE.size(1)-4,DISTANCE.size(2)-4];
end

if strcmp(sorting_type,'horton')
    STRAHLER.Z                  = matrices.(fields{5});
    STRAHLER.size               = [STRAHLER.size(1)-4,STRAHLER.size(2)-4];
end

if strcmp(pourpoints_points,'yes')
    POURPOINTS                   = FDIR;
    POURPOINTS.Z                 = matrices.(fields{10});
    POURPOINTS.size              = FDIR.size;
end

STREAMS                         = FDIR;
STREAMS.Z                       = matrices.(fields{6});
STREAMS.size                    = FDIR.size;

ID                              = FDIR;
ID.Z                            = matrices.(fields{7});
ID.size                         = FDIR.size;


% writes outputs to TIFF or ASCII 
% % -----------------------------------------------------------------------
mkdir('outputs');
mkdir('outputs\raster');
mkdir('outputs\csv');

addpath outputs/raster
addpath outputs/csv

fchan=['outputs/raster/',DEM.name,und];
fcsv=['outputs/csv/',DEM.name,'_result',datetime,'.csv'];


% % % -----------------------------------------------------------------------
if strcmpi(ext,'tif') || strcmpi(ext,'tiff') || strcmpi(ext,'geotif') || strcmpi(ext,'geotiff')
    GRIDobj2geotiff(STREAMS); %writes the matrix to geotiff
    if strcmp(internal_matrices ,'yes')
        GRIDobj2geotiff(ID,strcat(fchan,'id',datetime,'.tif'));
        GRIDobj2geotiff(FDIR,strcat(fchan,'flowdir',datetime,'.tif'));
        GRIDobj2geotiff(FA,strcat(fchan,'flowacc',datetime,'.tif'));
        if strcmp(hierarchy_attribute ,'distance')
            GRIDobj2geotiff(DISTANCE,strcat(fchan,'flowdist',datetime,'.tif'));
        end
        if strcmp(sorting_type,'horton')
            GRIDobj2geotiff(STRAHLER,strcat(fchan,'strahler',datetime,'.tif'));
        end
    end
    if strcmp(pourpoints_points,'yes')
        GRIDobj2geotiff(POURPOINTS,strcat(fchan,'POURPOINTS',datetime,'.tif'));
    end
else strcmpi(ext,'asc') || strcmpi(ext,'ascii') 
    GRIDobj2ascii(STREAMS); %writes the matrix to ascii
    if strcmp(internal_matrices ,'yes')
        GRIDobj2ascii(ID,strcat(fchan,'id',datetime,'.asc'));
        GRIDobj2ascii(FDIR,strcat(fchan,'flowdir',datetime,'.asc'));
        GRIDobj2ascii(FA,strcat(fchan,'flowacc',datetime,'.asc'));
        if strcmp(hierarchy_attribute ,'distance')
            GRIDobj2ascii(DISTANCE,strcat(fchan,'flowdist',datetime,'.asc'));
        end
        if strcmp(sorting_type,'horton')
            GRIDobj2ascii(STRAHLER,strcat(fchan,'strahler',datetime,'.asc'));
        end
    end
    if strcmp(pourpoints_points,'yes')
        GRIDobj2ascii(POURPOINTS,strcat(fchan,'POURPOINTS',datetime,'.asc'));
    end
end

%clear variables
% % -----------------------------------------------------------------------
clear DEM;
clear FDIR;
clear FA;
clear ID;

% writes output to a .csv
% % -----------------------------------------------------------------------
xi = find(STREAMS.Z >0);
[x,y] = ind2coord(STREAMS,xi);

area_value = matrices.(fields{2})(xi).*cell_area;

if strcmp(pourpoints_points,'yes')
    ppm = matrices.(fields{10})(xi);
else
    ppm = NaN(1,numel(xi))';
end

%exports values to csv with no headers for arcmap
% % -----------------------------------------------------------------------
dlmwrite(fcsv, [x y matrices.(fields{1})(xi) matrices.(fields{6})(xi) matrices.(fields{2})(xi) area_value matrices.(fields{7})(xi) matrices.(fields{8})(xi) ppm matrices.(fields{9})(xi)], 'precision', 8);

% plots streams_matrix in MATLAB
% % -----------------------------------------------------------------------
figure('NumberTitle', 'off', 'Name', 'Stream-network');
imageschs(DEMf,matrices.(fields{6}), 'ticklabels','nice','colorbar',true,'exaggerate',10);

end