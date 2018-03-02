function [xy_channel, xy_junction, order_junction, xy_dist_fin ] = build_channel( xy,  xy_channel, xy_junction, order_junction, xy_dist, order) 

% declare global variables
% % -----------------------------------------------------------------------
global dem_fill
global flowaccumulation
global flowdir
global flowdist
global strahler
global sorting_type
global hierarchy_attribute
global id_river

n            = true; 
ind_chan     = 1;
dist         = 0;

while n 
     
    xy_channel(ind_chan)          = xy; % first/new xy coord
    xy_dist(ind_chan)             = dist;
    
    %  preallocating arrays
    % % -------------------------------------------------------------------
    elevation_neighbors           = ones(1,9);
    flowacc_neighbors             = ones(1,9);
    flowdir_neighbors             = ones(1,9);
    coord_xy_neighbors            = ones(1,9);
    flowdist_neighbors            = ones(1,9);
    strahler_neighbors            = ones(1,9);
    n_rows                        = size(dem_fill,1);
    count                         = 1;  

    %  fills arrays with neighbors cells values       
    % % -------------------------------------------------------------------
    for i = [xy-n_rows, xy, xy+n_rows]
        for j = [-1, 0, +1]
            elevation_neighbors(count)           = dem_fill(i+j);
            flowacc_neighbors(count)             = flowaccumulation(i+j);
            flowdir_neighbors(count)             = flowdir(i+j);
            coord_xy_neighbors(count)            = i+j;
            if strcmp(hierarchy_attribute ,'distance')
                flowdist_neighbors(count)        = flowdist(i+j);
            elseif strcmp(hierarchy_attribute ,'accumulation')
                flowdist_neighbors               = '';
            end
            
            if strcmp(sorting_type,'horton')
                strahler_neighbors(count)        = strahler(i+j);
            elseif strcmp(sorting_type,'hack')
                strahler_neighbors               = '';
            end
            count = count + 1; 
        end
    end
    
    % finds next river cell    
    % % -------------------------------------------------------------------
    [xy, flowacc_neighbors, dist]             = find_next_river_cell(elevation_neighbors, flowacc_neighbors, flowdir_neighbors, flowdist_neighbors, strahler_neighbors, coord_xy_neighbors);

    % finds juntions neighbors to the river cell adressed     
    % % -------------------------------------------------------------------
    [xy_junction_i, order_junction_i]         = find_junction_cells(flowacc_neighbors, coord_xy_neighbors, strahler_neighbors, order);

    % if there is no new river cell (xy), then it has reached the head of a river
    % % -------------------------------------------------------------------
    if isempty(xy) 
        id_river        = id_river + 1;
        xy_dist_sum     = cumsum(xy_dist);
        xy_dist_fin     = xy_dist_sum(numel(xy_dist_sum)) - xy_dist_sum;
        n               = false; % breaks while loop, ends channel
    end

    % if river cell has junction cells around, adds its indices and orders
    % % -------------------------------------------------------------------
    if ~isempty(xy_junction_i)
        xy_junction    = [xy_junction, xy_junction_i]; % adds new xy junctions 
        order_junction = [order_junction, order_junction_i];
    end  
    
    ind_chan = ind_chan + 1; 
end
end