%% function: get centerline of the body
function [msh_center] = get_centerline(x, y, z, nel_x)

std_element_defs;

%% Find the center nodes:
tol = 1e-3;
idx_y = find( abs(y) <= tol );
idx_z = find( abs(z) <= tol );

idx = intersect( idx_y, idx_z);

% sort idx in x:
[~,idx_x] = sort( x(idx), 'ascend');
idx = idx(idx_x);

% make connectivity
% local numbering: 1 --- 3 --- 2
nel_center = nel_x;
eltype_center = zeros(nel_center,1) + 8;
IEN_center = zeros(nen(8), nel_center);
counter = -1;
for e = 1:nel_center
    counter = counter + 2;
    IEN_center(:,e) = [ idx(counter); idx(counter+2); idx(counter+1) ];
end


%% Export info
msh_center = struct('label', 'center_line' ,'num', nel_center, ...
    'max_dof_element_type', 8, ...
    'IEN', IEN_center, ...
    'etype', eltype_center,...
    'elements_contained', unique(eltype_center) );


end