%% File to generate FEM-based data
% file <main1.m>


%% clear up the workspace
clear all
close all
clc


%% Define parameters

% Load stepping details
% number of steps to take
N_load_steps = 3000;

% loading increment
DP   = 1e-5;

iter.max_steps = 200;
iter.rel_tol = 1e-12;

% Material constants
E0   = 1;
nu0  = 0.3;
rho0 = 1;

omega1 = 2*pi*1;

% E0   = 68.9e9;
% nu0  = 0.3;
% rho0 = 2700;

% Plate geometry
Lx = 3;
Ly = 1;
Lz = 0.1;

% Num. of Elements in each direction
nel_x = 4;
nel_y = 2;
nel_z = 1;

% Boundary conditions
% S: simply supported, C: clamp, F: free
BC_x0 = 'c';
BC_xL = 'c';


% Material Model
% 1= Kirchhoff, 2= Biot
matype0 = 1;

% Plotting options
flags.plot_ref = 0;
flags.plot_RestNodes = 1;
flags.plot_fancy = 1;
flags.plot_q0 = 0;
flags.plot_steps = 0;
flags.plot_steps_nskip = 10;
flags.plot_dampingFactors = 0;

% output options
flags.output.hdf5 = 1;

% check kill file
flags.checkKillFile = 1;


%% Set lesser used options

ROOTDIR = fullfile('../..');
% gmsh_exe = '~/software/gmsh-3.0.6-Linux64/bin/gmsh';
gmsh_exe= 'C:\Users\tim\software\gmsh\gmsh-2.10.1-Windows\gmsh.exe';
path(pathdef)
addpath(fullfile(ROOTDIR,'preprocmesh'));
addpath(fullfile(ROOTDIR,'assemble'));
addpath(fullfile(ROOTDIR,'postproc'));
addpath(fullfile(ROOTDIR,'quadrature'));
addpath(fullfile(ROOTDIR,'shapefunctions'));
addpath(fullfile(ROOTDIR,'timemarching'));


% std header
ned = 3;
std_element_defs;


%% Make a new FEM mesh
tempfile = 'temp';
if( gen_plate_geo( Lx, Ly, Lz, nel_x, nel_y, nel_z, [tempfile,'.geo']) ~= 0 )
    error('Cannot make geo file...');
end

cmd = sprintf('%s -3 %s', gmsh_exe, [tempfile,'.geo']);
if( system(cmd) ~= 0 )
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
E(1:nel)   = E0    ;
nu(1:nel)  = nu0   ;
rho(1:nel) = rho0  ;

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
[fix, A2] = apply_BC2face(msh, x, y, z, fix, 'face2', BC_xL);

% set which set of nodes the kinematic forcing is applied
A_kineForcing = union(A4, A2);


%% Construct the IM and LM Matricies
[ID, LM, neq, gg, nee, ng, freefree_range, freefix_range] = build_mesh(...
    nnp, IEN, g_list, nen, ned, nel, eltype, fix, 'resort', true, 'resort_fcn', @symamd);

%% plot reference configuration

if( flags.plot_ref > 0 )
    
    fig = figure();
    ax = axes('Parent',fig,'DataAspectRatio',[1 1 1]);
    
    hold(ax, 'on');
    xlabel(ax,'x');
    ylabel(ax,'y');
    zlabel(ax,'z');
    grid(ax,'on');
    
    xlim(ax, Lx*[-0.05, 1.05])
    ylim(ax, Ly*[-0.05, 1.05])
    
    title(ax, 'Reference plot' );
    
    [ps_nel, ps_eltype, ps_IEN] = parse_msh( msh, 'plot_surface');
    plot_element(ax,1:ps_nel,'g', ps_IEN, ps_eltype, x, y, z);
    
    qn = zeros(neq+ng, 1);
    %     plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A1, 'markercolor', 'm');
    %     plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A2, 'markercolor', 'r');
    %     plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A3, 'markercolor', 'y');
    plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A_kineForcing, 'markercolor', 'g');
    
    if( flags.plot_ref == 2 )
        % for debugging, stop the script here once the ref has been plotted
        return
    end
    
end

%% build Mass and Stiffness Matrices
ndofs = neq+ng;
qn = zeros(ndofs,1);

% Build index for fast assembly
[~,KK_idx_I,KK_idx_J] = get_nnz_CheckAssembly(LM,ned ,nen ,nnp ,nel, eltype);

% Build M
[M] = assemble_M(ned, nen, nnp, nel, eltype, ...
    KK_idx_I, KK_idx_J,...
    x, y, z, IEN, quad_rules, rho);
M1 = M(freefree_range,freefree_range);

% Build K
[K,~] = assemble_K(LM, ned, nen, nnp, nel, eltype, matype,...
    KK_idx_I, KK_idx_J,...
    E, x, y, z, IEN, ID, qn, quad_rules, nu);
K1 = K(freefree_range,freefree_range);

%% Scale E
lambda_1 = eigs(K1,M1,1,'sm');
E0 = omega1^2/lambda_1;
E(:) = E0;

% Build K
[K,~] = assemble_K(LM, ned, nen, nnp, nel, eltype, matype,...
    KK_idx_I, KK_idx_J,...
    E, x, y, z, IEN, ID, qn, quad_rules, nu);
K1 = K(freefree_range,freefree_range);


%% build the initial conditions:
q0 = zeros(ndofs,1);

%% Plot initial conditions
if flags.plot_q0
    % plot the initial conditions
    ps_alpha = 0.5;
    fig = figure();
    ax = axes('Parent', fig, 'DataAspectRatio', [1, 1, 1]);
    hold(ax, 'on');
    xlabel(ax,'x');
    ylabel(ax,'y');
    zlabel(ax,'z');
    grid(ax,'on');
    
    [ps_nel, ps_eltype, ps_IEN] = parse_msh( msh, 'plot_surface');
    
    if( flags.plot_fancy == 0 )
        plot_element_solution_hdsurf(ax, 1:ps_nel, 1, [0, 0, 1], ps_IEN, ID, ...
            ps_eltype, x, y, z, q0, ps_alpha, 0);
        
    elseif( flags.plot_fancy == 1 )
        plot_element_solution_hdsurf_coloredByDeformation(...
            ax, ps_IEN, ID, ps_eltype, x, y, z, q0, ...
            'field', 'displacement-z', ...
            'smoothing', 1, ...
            'alpha0', ps_alpha);
    end
end

%% Initialize output files
if flags.output.hdf5
    hfilename_datestr = datestr(now,'yyyy-mm-dd.HH-MM-SS');
    hfilename = sprintf('data.%s.h5', hfilename_datestr );
end

%% Integrate the solution in time: Generalized Alpha
minT = 2*pi/sqrt(eigs(K1,M1,1,'lm'));
maxT = 2*pi/sqrt(eigs(K1,M1,1,'sm'));
% dt = min([0.05, minT]);
% dt = 100*minT;
T_list = 2*pi./sqrt(eigs(K1,M1,10,'sm'));
%dt = T_list(6)/10; % 10 points in time for the 6th mode
dt = 20*minT;

% setup containers
qn   = q0;
qdn  = qd0;
qddn = zeros(ndofs,1);


% setup initial K and f_int
[~,f_int_n] = assemble_K(LM, ned, nen, nnp, nel, eltype, matype,...
    KK_idx_I, KK_idx_J,...
    E, x, y, z, IEN, ID, qn, quad_rules, nu);
f_int_n = f_int_n(freefree_range);

%% Init plot
if flags.plot_steps > 0
    
    % plot the initial conditions
    ps_alpha = 0.5;
    fig = figure();
    ax = axes('Parent', fig, 'DataAspectRatio', [1, 1, 1]);
    hold(ax, 'on');
    xlabel(ax,'x');
    ylabel(ax,'y');
    zlabel(ax,'z');
    grid(ax,'on');
    view(ax, [40,16]);
    
    zlim(ax, [-1,1]*4*Lz);
    xlim(ax, [-0.1,1]*1.2*Lx);
    ylim(ax, [-0.1,1.1]*Ly);
    
    [ps_nel, ps_eltype, ps_IEN] = parse_msh( msh, 'plot_surface');
    
    if flags.plot_fancy == 0
        hlist = plot_element_solution_hdsurf(ax, 1:ps_nel, 1, [0, 0, 1], ps_IEN, ID, ...
            ps_eltype, x, y, z, q0, ps_alpha, 0);
        
    elseif flags.plot_fancy == 1
        hlist = plot_element_solution_hdsurf_coloredByDeformation(...
            ax, ps_IEN, ID, ps_eltype, x, y, z, q0, ...
            'field', 'displacement-z', ...
            'smoothing', 1, ...
            'alpha0', ps_alpha);
    end
    
end


%%
% start the time march
fprintf(1,'----------------------\n');
fprintf(1,'Time Step:\n');
t = 0;
[qn, qdn, qddn] = setKinematics( t, qn, qdn, qddn, A_kineForcing, ID, kineForcingFcn);
for n = 1:N_t_steps
    
    [qn, qdn, qddn, iter] = genAlpha_step(t,dt,qn,qdn,qddn, ...
        M, M1, D, D1, rho_inf, ...
        LM, ned, nen, nnp, nel, eltype, matype,...
        KK_idx_I, KK_idx_J,...
        E, x, y, z, IEN, ID, quad_rules, nu,...
        freefree_range, freefix_range,...
        A_kineForcing, kineForcingFcn);
    
    t = t+dt;    
    
    % output results
    if flags.output.hdf5
        write_hdf5_snapshot(hfilename, n, qn, qdn, t, 'qddn', qddn, 'writeDateTime', true, 'subIter', iter.i);
    end
    
    %%
    % update plot(s)
    if flags.plot_steps == 1 && mod(n,flags.plot_steps_nskip) == 0
        delete(hlist);
        if flags.plot_fancy == 0
            hlist = plot_element_solution_hdsurf(ax, 1:ps_nel, 1, [0, 0, 1], ps_IEN, ID, ...
                ps_eltype, x, y, z, qn, ps_alpha, 0);
            
        elseif flags.plot_fancy == 1
            hlist = plot_element_solution_hdsurf_coloredByDeformation(...
                ax, ps_IEN, ID, ps_eltype, x, y, z, qn, ...
                'field', 'displacement-z', ...
                'smoothing', 1, ...
                'alpha0', ps_alpha,...
                'scalefactor', 1);
        end
        
        title(sprintf('n=%5d, t= %5.2e', n, t) );
        
        pause(0.01);
    end
    
    
    %%
    % check killflag
    if flags.checkKillFile
        flags.kill = checkKillFile();
        if flags.kill
            break
        end
    end
    
    
end
N_t_endstep = n;

%%
if flags.output.hdf5
    save(['data.',hfilename_datestr,'.mat']);
end


%%
if flags.checkKillFile
    checkKillFile('remove', 1);
end
