function [xy_pourpoint_i, order_pourpoint_i]         = find_pourpoints_cells(s, order)
% declare global variables
% % -----------------------------------------------------------------------
global min_drainage_area
global max_trib_order
global cell_area
global sorting_type

% returns pp empty if no neighbour meets the below conditions
% % -----------------------------------------------------------------------
xy_pourpoint_i                = [];
order_pourpoint_i             = [];

flowacc_drainage             = s.flowacc_neighbors.*cell_area; % turns array with accumulation values to an array with drainage area values
index_value                  = find(flowacc_drainage >= min_drainage_area); % selects indices of elements with equal or higher drainage basin area value than drainage_basin


% grabs pourpoints indices if there are cell/s that met the above condition
% % -----------------------------------------------------------------------
if ~((isempty(index_value) || (isempty(max_trib_order) == 0 && order == max_trib_order)))  
    
    %  preallocating arrays
    % % -------------------------------------------------------------------
    xy_pourpoint_i    = ones(1,numel(index_value));
    order_pourpoint_i = ones(1,numel(index_value));
    
    for i = 1:numel(index_value)         
        xy_pourpoint_i(i) = s.coord_xy_neighbors(index_value(i));
        if strcmp(sorting_type,'hack')
            order_pourpoint_i(i)       = order+1;
        elseif strcmp(sorting_type,'horton')
            order_pourpoint_i(i)       = s.strahler_neighbors(index_value(i));
        end
    end
end
end

