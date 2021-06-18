%% main4: get centerline of the body

clear variables
close all
clc

%% load preprocessed data
% load the mesh and properties
load('mesh.mat')

path(pathdef)
ROOTDIR = fullfile('../..');
addpath(fullfile(ROOTDIR,'preprocmesh'));
addpath(fullfile(ROOTDIR,'assemble'));
addpath(fullfile(ROOTDIR,'postproc'));
addpath(fullfile(ROOTDIR,'shapefunctions'));

% std header
ned = 3;
std_element_defs;

%%
flags.plot_ref = 1;
flags.plot_RestNodes = 1;
flags.plot_fancy = 1;


[fig,ax,hlist] = plot_ref(x, y, z, ID, neq, ng, msh, flags, A_Fext, A_BC);


%% Find the center nodes:
tol = 1e-3;
idx_y = find( abs(y) <= tol );
idx_z = find( abs(z) <= tol );

idx = intersect( idx_y, idx_z);

temp = plot_node_labels(ax, idx', x, y, z);
hlist = [hlist,temp];
clear temp

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
IEN_center

%% Draw elment 8:
%TODO: derive 3-node line (element type 8) shape function, and make
%plotting routines
qn = zeros(ndofs,1);
hlist = plot_element_solution_hdsurf2(ax, 1:nel_center, IEN_center, ID,...
    eltype_center, x, y, z, qn, 'line_width', 4);



