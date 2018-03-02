function [xy_junction_i, order_junction_i] = find_junction_cells(flowacc_neighbors, coord_xy_neighbors, strahler_neighbors, order)

% declare global variables
% % -----------------------------------------------------------------------
global min_drainage_area
global max_trib_order
global cell_area
global sorting_type

% returns pp empty if no neighbour meets the below conditions
% % -----------------------------------------------------------------------
xy_junction_i                = [];
order_junction_i             = [];

flowacc_drainage             = flowacc_neighbors.*cell_area; % turns array with accumulation values to an array with drainage area values
index_value                  = find(flowacc_drainage >= min_drainage_area); % selects indices of elements with equal or higher drainage basin area value than drainage_basin

% grabs junctions indices if there are cell/s that met the above condition
% % -----------------------------------------------------------------------
if ~((isempty(index_value) || (isempty(max_trib_order) == 0 && order == max_trib_order)))  
    
    %  preallocating arrays
    % % -------------------------------------------------------------------
    xy_junction_i    = ones(1,numel(index_value));
    order_junction_i = ones(1,numel(index_value));
    
    for i = 1:numel(index_value)         
        xy_junction_i(i) = coord_xy_neighbors(index_value(i));
        if strcmp(sorting_type,'hack')
            order_junction_i(i)       = order+1;
        elseif strcmp(sorting_type,'horton')
            order_junction_i(i)       = strahler_neighbors(index_value(i));
        end
    end
end
end

