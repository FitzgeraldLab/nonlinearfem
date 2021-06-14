%% File to generate FEM-based data
% file <main1.m>


%% clear up the workspace
clear all
close all
clc


%% Define parameters

% loading location info
Fext_location = "L"; % center, edge, span
Fext_surface = "center"; % top, center, or bottom
Fext_direction = 3; % 1->x, 2->y, 3->z

% Material constants
rho0 = 1;
E0   = 1;
nu0  = 0.3;
omega1 = 2*pi*1; % [1 hz to rad/s]
zetaN  = 0.5; % damping factor of the highest frequency resolved

% E0   = 68.9e9;
% nu0  = 0.3;

% Plate geometry
Lx = 1;
Ly = 0.05;
Lz = Ly;

% Num. of Elements in each direction
nel_x = 10;
nel_y = 2;
nel_z = nel_y;

% Boundary conditions
% S: simply supported, C: clamp, F: free
BC_x0 = 'c';
BC_xL = 'f';

% Material Model
% 1= Kirchhoff, 2= Biot
matype0 = 2;

%% Plotting options
flags.plot_ref = 1;
flags.plot_RestNodes = 1;
flags.plot_fancy = 1;

%% Set lesser used options

ROOTDIR = fullfile('../..');
if ispc
    gmsh_exe= [getenv('USERPROFILE'),'\software\gmsh\gmsh-2.16.0-Windows\gmsh.exe'];
else
    gmsh_exe = '~/software/gmsh-3.0.6-Linux64/bin/gmsh';
end
path(pathdef)
addpath(fullfile(ROOTDIR,'preprocmesh'));
addpath(fullfile(ROOTDIR,'assemble'));
addpath(fullfile(ROOTDIR,'postproc'));
addpath(fullfile(ROOTDIR,'quadrature'));
addpath(fullfile(ROOTDIR,'shapefunctions'));

% std header
ned = 3;
std_element_defs;


%% Make a new FEM mesh
tempfile = 'temp';
if( gen_plate_geo( Lx, Ly, Lz, nel_x, nel_y, nel_z, [tempfile,'.geo']) ~= 0 )
    error('Cannot make geo file...');
end

cmd = sprintf('%s -3 %s', gmsh_exe, [tempfile,'.geo']);
if( system(cmd) < 0 )
    error('Cannot GMSH the geo file');
end


%% Load the msh into matlab
[Nodes, msh, PhysicalName] = load_gmsh([tempfile,'.msh']);

% parse node locations
x = Nodes.x;
y = Nodes.y;
z = Nodes.z;
nnp = length(x);

[nel, eltype, IEN] = parse_msh(msh, 'body');

% Material Properties
% define matrial properties for each element:
rho(1:nel) = rho0  ;
E(1:nel)   = E0    ;
nu(1:nel)  = nu0   ;

%% Rescale y-z plane to be circular

[y,z] = rescale_square2circle(y,z,Ly, Lz);


%% generate or load gaussian quadrature information
quad_rules = set_integration_rules( eltype );


%% set which material model to use
%   Krichhoff = 1; Biot = 2
matype = zeros(nel,1) + matype0;


%% Apply BC's
% generate BC tables for all nodes
fix = sparse(ned,nnp);
g_list = sparse(ned,nnp); % all are always zero

%    ----- 3 ------
%    |            |
%    |            |
%    4            2
% y  |            |
% |  |            |
% |  ----- 1 ------
% --x
%

% BC's for X = 0
[fix, A4] = apply_BC2face(msh, x, y, z, fix, 'face4', BC_x0);

% BC's for X = L
% [fix, A2] = apply_BC2face(msh, x, y, z, fix, 'face2', BC_xL);

% set which set of nodes the kinematic forcing/BC is applied
% A_BC = union(A4, A2);
A_BC = A4;

%% External forcing on nodes
% find the set of nodes where the external forces directly act.  Be sure
% that these nodes are NOT on a boundary.
A_Fext = find_A_ExtLoad(Fext_location, Fext_surface, ...
    Lx, Ly, Lz, x, y, z);

%% Construct the IM and LM Matricies
[ID, LM, neq, gg, nee, ng, freefree_range, freefix_range] = build_mesh(...
    nnp, IEN, g_list, nen, ned, nel, eltype, fix, 'resort', true, 'resort_fcn', @symamd);

%% plot reference configuration
if flags.plot_ref > 0 
    plot_ref(Lx, Ly, x, y, z, ID, neq, ng, msh, flags, A_Fext, A_BC);
end

%% build Mass and Stiffness Matrices
ndofs = neq+ng;
qn = zeros(ndofs,1);

% Build index for fast assembly
[~,KK_idx_I,KK_idx_J] = get_nnz_CheckAssembly(LM, ned, nen, nnp, nel, ...
    eltype);

% Build K once to check if there are errors.
[K,~] = assemble_K(LM, ned, nen, nnp, nel, eltype, matype,...
    KK_idx_I, KK_idx_J,...
    E, x, y, z, IEN, ID, qn, quad_rules, nu);
K1 = K(freefree_range,freefree_range);

% Build M
[M] = assemble_M(ned, nen, nnp, nel, eltype, ...
    KK_idx_I, KK_idx_J,...
    x, y, z, IEN, quad_rules, rho);
M1 = M(freefree_range,freefree_range);

%% Scale E
lambda_1 = eigs(K1,M1,1,'sm');
E0 = omega1^2/lambda_1;
E(:) = E0;

%% Build the damping matrix
% [D] = kappa_m*[M] + kappa_k*[K]

[K,~] = assemble_K(LM, ned, nen, nnp, nel, eltype, matype,...
    KK_idx_I, KK_idx_J,...
    E, x, y, z, IEN, ID, qn, quad_rules, nu);
K1 = K(freefree_range,freefree_range);

% mass damping
kappa_m = 0;

omega_n = sqrt(eigs(K1,M1,1,'lm'));
% omega_list = sort(sqrt(eig(full(K1),full(M1))));
kappa_k = 2*zetaN/omega_n;
D = kappa_m*M + kappa_k*K;
D1 = D(freefree_range, freefree_range);


%% Pack the outputs
save('mesh.mat', 'msh', ...
    'x', 'y', 'z', 'nnp', 'nel', 'eltype', 'IEN', 'rho', 'quad_rules', ...
    'E', 'nu', 'ID', 'LM', 'neq', 'gg', 'ng', 'freefree_range', ...
    'freefix_range', 'ndofs', 'KK_idx_I', 'KK_idx_J', 'omega1', 'zetaN',...
    'matype', 'A_Fext', 'A_BC', 'Fext_direction', 'M', 'D', 'K');
