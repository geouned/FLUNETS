function [ streams_matrix, id_matrix, dist_matrix, junction_matrix ] = build_channel_network(  xy_junction_copy, order_junction_copy, streams_matrix, id_matrix, dist_matrix, junction_matrix)

% declare global variables
% % -----------------------------------------------------------------------
global sorting_type
global max_trib_order
global junctions_points
global id_river

% generate variables
% % -----------------------------------------------------------------------
order                   = 1;
condition               = true;

% extracts channel network
% % -----------------------------------------------------------------------
while condition
    
    xy_junction         = [];
    order_junction      = [];
    
    for i = 1:numel(xy_junction_copy) % for each junction index
        xy_channel          = []; % for all streams of same loop        
        xy                  = xy_junction_copy(i);
        xy_dist             = [];
                
        if strcmp(sorting_type,'hack')
            order_xy_value      =  order;
        elseif strcmp(sorting_type,'horton')
            order_xy_value      =  order_junction_copy(i);
        end
        [xy_channel, xy_junction, order_junction, xy_dist_fin ] = build_channel(xy,  xy_channel, xy_junction, order_junction, xy_dist, order);
        
        % fills streams_matrix for each individual channel
        % % ---------------------------------------------------------------
        if ~isempty(xy_channel)
            for a = 1:numel(xy_channel)
                streams_matrix(xy_channel(a))                 = order_xy_value;
                id_matrix(xy_channel(a))                      = id_river;
                dist_matrix(xy_channel(a))                    = xy_dist_fin(a);
            end
        end
    end

    % ends while loop when xy_juntion is empty or order = max_trib_order, else fills junctions_arrays
    % % ------------------------------------------------------------------
    if (isempty(xy_junction) || (isequal(order,max_trib_order))) 
        condition = false; %ends programme
    else
        xy_junction_copy            = xy_junction;% copies junctions indices of same loop rivers
        order_junction_copy         = order_junction;

        % fills junction_matrix        
        % % ---------------------------------------------------------------
        if strcmp(junctions_points,'yes')            
            for a = 1:numel(xy_junction)
                junction_matrix(xy_junction(a)) = order_junction(a);
            end
        end
    end
    order = order + 1;
end
end