function streams_matrix = build_streams_map(inputs) 

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
global dem_fill
global flowdir
global flowaccumulation
global flowdist
global strahler
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

% declare var matrices
% % -----------------------------------------------------------------------
dem_fill              = DEMf.Z; 
flowaccumulation      = FA.Z;
flowdir               = FDIR.Z;
flowdist              = '';
strahler              = '';
if strcmp(hierarchy_attribute ,'distance')
    DISTANCE                        = flowdistance(FD,S,'downstream');
    DISTANCE.Z(DISTANCE.Z<=0)       = NaN; %replace 0 and arcmap nan values with NaN
    flowdist                        = DISTANCE.Z;
end

if strcmp(sorting_type ,'horton')
    STRAHLER                        = streamorder(FD,flowacc(FD)>1,'strahler');
    stra                            = double(STRAHLER.Z);
    stra(stra<=0)                   = NaN; %replace 0 and arcmap nan values with NaN  
    strahler                        = stra;
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

clear S;
clear FD;


% generates NaN matrices same size of flowaccumulation matrix
% % -----------------------------------------------------------------------
streams_matrix      = NaN(size(flowaccumulation));
id_matrix           = NaN(size(flowaccumulation));
dist_matrix         = NaN(size(flowaccumulation));
outlet_matrix       = NaN(size(flowaccumulation));

for a = 1:numel(outlet_z)
    outlet_matrix(outlet_z(a)) = 1;
end

if strcmp(pourpoints_points,'yes')    
    pourpoint_matrix     = NaN(size(flowaccumulation));
else
    pourpoint_matrix     = [];
end

% loops through each outlet to extract and order each channel network
% % -----------------------------------------------------------------------
for item = 1:numel(outlet_z)    
    xy_pourpoint_copy = outlet_z(item);    
    xy_area = flowaccumulation(xy_pourpoint_copy)*cell_area;       
    if xy_area >= min_drainage_area    
        switch sorting_type
            case 'hack'
                order_pourpoint_copy     = '';
            case 'horton'
                order_pourpoint_copy     = strahler(xy_pourpoint_copy);
        end

        % calls build_channelnetwork function
        % % -------------------------------------------------------------------
        [streams_matrix, id_matrix, dist_matrix, pourpoint_matrix] = build_channel_network( xy_pourpoint_copy, order_pourpoint_copy, streams_matrix, id_matrix, dist_matrix, pourpoint_matrix);

    end
end
% removes the padding 
% % -----------------------------------------------------------------------
streams_matrix      = streams_matrix(3:size(streams_matrix,1)-2,3:size(streams_matrix,2)-2); 
id_matrix           = id_matrix(3:size(id_matrix,1)-2,3:size(id_matrix,2)-2); 
dist_matrix         = dist_matrix(3:size(dist_matrix,1)-2,3:size(dist_matrix,2)-2); 
outlet_matrix       = outlet_matrix(3:size(outlet_matrix,1)-2,3:size(outlet_matrix,2)-2); 

if strcmp(pourpoints_points,'yes')    
    pourpoint_matrix     = pourpoint_matrix(3:size(pourpoint_matrix,1)-2,3:size(pourpoint_matrix,2)-2);
end

dem_fill            = dem_fill(3:size(dem_fill,1)-2,3:size(dem_fill,2)-2);
flowdir             = flowdir(3:size(flowdir,1)-2,3:size(flowdir,2)-2);
flowaccumulation    = flowaccumulation(3:size(flowaccumulation,1)-2,3:size(flowaccumulation,2)-2);
if strcmp(hierarchy_attribute ,'distance')
    flowdist        = flowdist(3:size(flowdist,1)-2,3:size(flowdist,2)-2);
end
if strcmp(sorting_type,'horton')
    strahler        = strahler(3:size(strahler,1)-2,3:size(strahler,2)-2);
end

% resize and turn matrices to GRIDobjs
% % -----------------------------------------------------------------------
DEMf.Z                          = dem_fill;
DEMf.size                       = [DEMf.size(1)-4,DEMf.size(2)-4];

FDIR.Z                          = flowdir;
FDIR.size                       = [FDIR.size(1)-4,FDIR.size(2)-4];

FA.Z                            = flowaccumulation;
FA.size                         = [FA.size(1)-4,FA.size(2)-4];

if strcmp(hierarchy_attribute ,'distance')
    DISTANCE.Z                  = flowdist;
    DISTANCE.size               = [DISTANCE.size(1)-4,DISTANCE.size(2)-4];
end

if strcmp(sorting_type,'horton')
    STRAHLER.Z                  = strahler;
    STRAHLER.size               = [STRAHLER.size(1)-4,STRAHLER.size(2)-4];
end

if strcmp(pourpoints_points,'yes')
    POURPOINTS                   = FDIR;
    POURPOINTS.Z                 = pourpoint_matrix;
    POURPOINTS.size              = FDIR.size;
end

STREAMS                         = FDIR;
STREAMS.Z                       = streams_matrix;
STREAMS.size                    = FDIR.size;

ID                              = FDIR;
ID.Z                            = id_matrix;
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


% % -----------------------------------------------------------------------
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

%  preallocating arrays
% % -----------------------------------------------------------------------
riv_value  = NaN(1,numel(xi));
z          = NaN(1,numel(xi));
acc_value  = NaN(1,numel(xi));
id_value   = NaN(1,numel(xi)); 
dis_value  = NaN(1,numel(xi));
out_value  = NaN(1,numel(xi));
pourpoint_value  = NaN(1,numel(xi)); 


for i = 1:numel(xi)
    riv_value(i) = streams_matrix(xi(i));
    z(i)         = dem_fill(xi(i));
    acc_value(i) = flowaccumulation(xi(i));
    id_value(i)  = id_matrix(xi(i));
    dis_value(i) = dist_matrix(xi(i));
    out_value(i) = outlet_matrix(xi(i));
    if strcmp(pourpoints_points,'yes')
        pourpoint_value(i) = pourpoint_matrix(xi(i));
    end
end

area_value = acc_value.*cell_area;

%exports values to csv with no headers for arcmap
% % -----------------------------------------------------------------------
dlmwrite(fcsv, [x y z' riv_value' acc_value' area_value' id_value' dis_value' pourpoint_value' out_value'], 'precision', 8);

% plots streams_matrix in MATLAB
% % -----------------------------------------------------------------------
figure('NumberTitle', 'off', 'Name', 'Stream-network');
imageschs(DEMf,streams_matrix, 'ticklabels','nice','colorbar',true,'exaggerate',10);

end