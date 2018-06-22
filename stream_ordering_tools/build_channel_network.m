% function [streams_matrix, id_matrix, dist_matrix, pourpoint_matrix] = build_channel_network( xy_pourpoint_copy, order_pourpoint_copy, streams_matrix, id_matrix, dist_matrix, pourpoint_matrix)
function [matrices] = build_channel_network( xy_pourpoint_copy, order_pourpoint_copy, matrices)

% declare global variables
% % -----------------------------------------------------------------------
global sorting_type
global max_trib_order
global pourpoints_points
global id_river
global fields

% generate variables
% % -----------------------------------------------------------------------
order                   = 1;
condition               = true;

% extracts channel network
% % -----------------------------------------------------------------------
while condition
    
    xy_pourpoint         = [];
    order_pourpoint      = [];
    
    for i = 1:numel(xy_pourpoint_copy) % for each pourpoint index
        xy_channel          = []; % for all streams of same loop
        xy                  = xy_pourpoint_copy(i);
        xy_dist             = [];
        
        if strcmp(sorting_type,'hack')
            order_xy_value      =  order;
        elseif strcmp(sorting_type,'horton')
            order_xy_value      =  order_pourpoint_copy(i);
        end
        %         [xy_channel, xy_pourpoint, order_pourpoint, xy_dist_fin ] = build_channel(xy,  xy_channel, xy_pourpoint, order_pourpoint, xy_dist, order);
        [xy_channel, xy_pourpoint, order_pourpoint, xy_dist_fin, matrices ] = build_channel(xy,  xy_channel, xy_pourpoint, order_pourpoint, xy_dist, order, matrices);
        
        % fills streams_matrix for each individual channel
        % % ---------------------------------------------------------------
        if ~isempty(xy_channel)
            for a = 1:numel(xy_channel)
                matrices.(fields{6})(xy_channel(a))    = order_xy_value;
                matrices.(fields{7})(xy_channel(a))    = id_river;
                matrices.(fields{8})(xy_channel(a))    = xy_dist_fin(a);
            end
        end
    end
    
    % ends while loop when xy_pourpoint is empty or order = max_trib_order, else fills pourpoints_arrays
    % % ------------------------------------------------------------------
    if (isempty(xy_pourpoint) || (isequal(order,max_trib_order)))
        condition = false; %ends programme
    else
        xy_pourpoint_copy            = xy_pourpoint;% copies pourpoints indices of same loop rivers
        order_pourpoint_copy         = order_pourpoint;
        
        % fills pourpoint_matrix
        % % ---------------------------------------------------------------
        if strcmp(pourpoints_points,'yes')
            for a = 1:numel(xy_pourpoint)
                matrices.(fields{10})(xy_pourpoint(a)) = order_pourpoint(a);
            end
        end
    end
    order = order + 1;
end
end