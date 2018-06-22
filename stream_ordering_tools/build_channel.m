function [xy_channel, xy_pourpoint, order_pourpoint, xy_dist_fin ] = build_channel(xy,  xy_channel, xy_pourpoint, order_pourpoint, xy_dist, order)

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
    names = [{'elevation_neighbors'}, {'flowacc_neighbors'}, {'flowdir_neighbors'}, {'coord_xy_neighbors'}, {'flowdist_neighbors'}, {'strahler_neighbors'}];
    
    s = struct;
    for i = names
        s.(i{1,1}) = ones(1,9);
    end
    
    n_rows                        = size(dem_fill,1);
    count                         = 1;
    
    %  fills arrays with neighbors cells values
    % % -------------------------------------------------------------------
    for i = [xy-n_rows, xy, xy+n_rows]
        for j = [-1, 0, +1]
            s.(names{1})(count)           = dem_fill(i+j);
            s.(names{2})(count)           = flowaccumulation(i+j);
            s.(names{3})(count)           = flowdir(i+j);
            s.(names{4})(count)           = i+j;
            if strcmp(hierarchy_attribute ,'distance')
                s.(names{5})(count)        = flowdist(i+j);
            elseif strcmp(hierarchy_attribute ,'accumulation')
                s.(names{5})               = '';
            end
            
            if strcmp(sorting_type,'horton')
                s.(names{6})(count)       = strahler(i+j);
            elseif strcmp(sorting_type,'hack')
                s.(names{6})              = '';
            end
            count = count + 1;
        end
    end
    
    % finds next river cell
    % % -------------------------------------------------------------------
    [xy, s, dist]             = find_next_river_cell(s);

    % finds juntions neighbors to the river cell adressed
    % % -------------------------------------------------------------------
    [xy_pourpoint_i, order_pourpoint_i]         = find_pourpoints_cells(s, order);

    % if there is no new river cell (xy), then it has reached the head of a river
    % % -------------------------------------------------------------------
    if isempty(xy)
        id_river        = id_river + 1;
        xy_dist_sum     = cumsum(xy_dist);
        xy_dist_fin     = xy_dist_sum(numel(xy_dist_sum)) - xy_dist_sum;
        n               = false; % breaks while loop, ends channel
    end
    
    % if river cell has pourpoint cells around, adds its indices and orders
    % % -------------------------------------------------------------------
    if ~isempty(xy_pourpoint_i)
        xy_pourpoint    = [xy_pourpoint, xy_pourpoint_i]; % adds new xy pourpoints
        order_pourpoint = [order_pourpoint, order_pourpoint_i];
    end
    
    ind_chan = ind_chan + 1;
end
end