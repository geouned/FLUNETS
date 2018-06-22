function [xy, s, dist]   = find_next_river_cell(s)
% declare global variables
% % -----------------------------------------------------------------------
global cell_size
global fdir_values
global hierarchy_attribute
global sorting_type

%  preallocating arrays
% % -----------------------------------------------------------------------
xy                                    = []; % if no condiction below is met, returns empty coords, end of the river 
river_candidate                       = NaN(1,numel(s.elevation_neighbors));
elevation_candidate                   = NaN(1,numel(s.elevation_neighbors));
pos                                   = 0;
dist                                  = 0;


if strcmp(hierarchy_attribute,'accumulation')
    river_value                       = s.flowacc_neighbors(5);
    flow_neighbors                    = s.flowacc_neighbors;
elseif strcmp(hierarchy_attribute,'distance')
    river_value                       = s.flowdist_neighbors(5);
    flow_neighbors                    = s.flowdist_neighbors;
end

% selects cells that meet the conditions
% % -----------------------------------------------------------------------
if strcmp(sorting_type,'hack')
    for i = 1:numel(s.elevation_neighbors) 
        if isequal(s.flowdir_neighbors(i), fdir_values(i)) && (flow_neighbors(i)<=river_value) && ~isnan(flow_neighbors(i))
            river_candidate(i)       = flow_neighbors(i); % if true, passes accumulation value to river_candidate keeping element position
        else
            s.flowacc_neighbors(i)     = NaN; % if element does not flow to river cell, its element value is turned to 0 in val4flowacc
        end
    end
    
elseif  strcmp(sorting_type,'horton')
    strahler_river_value              = s.strahler_neighbors(5);
    for i = 1:numel(s.elevation_neighbors) % for each element in val4flowacc array
        if isequal(s.strahler_neighbors(i), strahler_river_value) && isequal(s.flowdir_neighbors(i), fdir_values(i)) && (flow_neighbors(i)<=river_value)
            xy                        = s.coord_xy_neighbors(i);
            s.flowacc_neighbors(i)      = NaN;
            pos                       = i;
        elseif (isequal(s.flowdir_neighbors(i), fdir_values(i)) && (flow_neighbors(i)<=river_value) && ~isnan(flow_neighbors(i)))% selects those elements which flow into river-cell
            river_candidate(i)        = flow_neighbors(i); % if true, passes accumulation value to val4flowacc_possible keeping element position
        else
            s.flowacc_neighbors(i)      = NaN; % if element does not flow to river cell, its element value is turned to 0
        end
    end
end

% if there are more than 1 cell meeting the conditions, selects the one
% with the highest acc/dist value or second check: min elevation
% % -----------------------------------------------------------------------
if isempty(xy) 
    [~,index] = find(river_candidate == max(river_candidate));% gets indices of highest elements
    if  (numel(index) == 1) % if there is an only element, it is the new river cell to be assessed
        xy                            = s.coord_xy_neighbors(index);
        pos                           = index;
        s.flowacc_neighbors(index)      = NaN;
    elseif (numel(index)  > 1) % if more than one element fit the condition, selects the one with lowest elevation
        for i = index
            elevation_candidate(i)    = s.elevation_neighbors(i);
        end
        [~,index_elevation]           = min(elevation_candidate); % gets 1 minimum
        xy                            = s.coord_xy_neighbors(index_elevation);
        pos                           = index_elevation;
        s.flowacc_neighbors(index_elevation) = NaN;
    end
end

%stores distance
% % -----------------------------------------------------------------------
ind_pos_01 = (2:2:8);
ind_pos_02 = [(1:2:3),(7:2:9)];

if ismember(pos,ind_pos_01)  
    dist = cell_size;
elseif ismember(pos,ind_pos_02) 
    dist = sqrt(power(cell_size,2)+ power(cell_size,2));    
end
