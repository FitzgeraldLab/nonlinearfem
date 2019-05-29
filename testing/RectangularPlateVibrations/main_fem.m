%% main_fem
% Example FEM check of a rectanglur solid.  If the body is thin, and
% simply-supported on all the edges, then it can be checked against
% classical theory.


%% clear up the workspace
clear all;
close all
clc


%% Define parameters

% Material constants
E0   = 1;
nu0  = 0.3;
rho0 = 1;

% Plate geometry
Lx = 1;
Ly = 1;
Lz = 0.001;

% Num. of Elements in each direction
nel_x = 10;
nel_y = 10;
nel_z = 1;

% Boundary conditions
% S: simply supported, C: clamp, F: free
BC_x0 = 's';
BC_xL = 's';
BC_y0 = 's';
BC_yL = 's';
flags.check_analyticSSSS = 1;

% Material Model
% 1= Kirchhoff, 2= Biot
% since the problem is linear, both models are identical
matype0 = 1;

% number of eigenvalues to compute
n_eigenvalues = 10;

% Plotting options
flags.plot_modes = 1;
flags.plot_RestNodes = 1;
flags.plot_fancy = 1;
flags.plot_ref = 0;


%% Set lesser used options

ROOTDIR = fullfile('../..');
% gmsh_exe = 'c:\Users\tim\Downloads\gmsh-2.8.5-Windows\gmsh.exe';
gmsh_exe = '/home/fitzgeraldt/software/gmsh-2.11.0-Linux/bin/gmsh';
path(pathdef)
addpath(fullfile(ROOTDIR,'preprocmesh'));
addpath(fullfile(ROOTDIR,'assemble'));
addpath(fullfile(ROOTDIR,'postproc'));
addpath(fullfile(ROOTDIR,'quadrature'));
addpath(fullfile(ROOTDIR,'shapefunctions'));


% std header
ned = 3;
std_element_defs;

% nondimensionalizing parameter
% $ \lambda = \omega  a^2  \sqrt{ \rho / D }$
D = E0*Lz^3 / (12 *(1-nu0^2));
nodim = Lx^2 * sqrt( (rho0*Lz)/D );


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

% BC's for X = Lx
[fix, A2] = apply_BC2face(msh, x, y, z, fix, 'face2', BC_xL);

% BC's for Y = 0
[fix, A1] = apply_BC2face(msh, x, y, z, fix, 'face1', BC_y0);

% BC's for Y = Ly
[fix, A3] = apply_BC2face(msh, x, y, z, fix, 'face3', BC_yL);


%% Construct the IM and LM Matricies
[ID, LM, neq, gg, nee, ng, r1] = build_mesh(...
    nnp, IEN, g_list, nen, ned, nel, eltype, fix);


%% plot reference configuration

if( flags.plot_ref > 0 && flags.plot_modes > 0 )
    
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
    plot_node_solution(ax, A1, 'm' , 1, x, y, z, qn, ID);
    plot_node_solution(ax, A2, 'r' , 1, x, y, z, qn, ID);
    plot_node_solution(ax, A3, 'y' , 1, x, y, z, qn, ID);
    plot_node_solution(ax, A4, 'g' , 1, x, y, z, qn, ID);
    
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
M = M(r1,r1);

% Build K
[K,~] = assemble_K(LM, ned, nen, nnp, nel, eltype, matype,...
                   KK_idx_I, KK_idx_J,...
                   E, x, y, z, IEN, ID, qn, quad_rules, nu);
K = K(r1,r1);


%% Compute the first several eigenvalues
[V, D]= eigs(K,M,n_eigenvalues,'sm');
[omega, idx] = sort( sqrt(diag(D)) );
V = V(:,idx);


fprintf(1,'\n\n');
fprintf(1,'--------------------------------------------------------\n');
fprintf(1, 'nel_x =%3d, nel_y =%3d, nel_z =%3d: \n', nel_x, nel_y, nel_z);


%% Analytic approx

if( flags.check_analyticSSSS )
    BC_x = 'SS';
    BC_y = 'SS';
    
    m_list = 2:(2+n_eigenvalues);
    n_list = 2:(2+n_eigenvalues);
    lambda = zeros(length(m_list), length(n_list));
    for i = 1:length(m_list)
        for j = 1:length(n_list)
            lambda(i,j) = plate_naturalfreq( Lx, m_list(i), Ly, n_list(j), BC_x, BC_y, nu0);
        end
    end
    lambda = sort(lambda(:));
    
    fprintf(1, ' i |  Analytic     |   FEM          |  Rel. Error %%\n');
    for i = 1:min([length(lambda), n_eigenvalues])
        fprintf( 1, '%2d: %15.9f, %15.9f, %10.3e\n', i, lambda(i), omega(i)*nodim,  (omega(i)*nodim/lambda(i)-1)*100 );
    end
    
else
    
    for i = 1:n_eigenvalues
        fprintf( 1, '%2d: %15.9f\n', i, omega(i)*nodim );
    end
    
end


%% Plot mode shapes

if( flags.plot_modes == 1 )
    
    ps_alpha = 0.5;
    ps_max = Lx/10;
    
    for  i = 1:n_eigenvalues
        
        fig = figure();
        ax = axes('Parent', fig, 'DataAspectRatio', [1, 1, 1]);
        hold(ax, 'on');
        xlabel(ax,'x');
        ylabel(ax,'y');
        zlabel(ax,'z');
        grid(ax,'on');
        
        xlim(ax, Lx*[-0.05, 1.05]);
        ylim(ax, Ly*[-0.05, 1.05]);
        
        title(ax, sprintf('\\omega_{%d} = %.4f', i, omega(i) ) );
        
        [ps_nel, ps_eltype, ps_IEN] = parse_msh( msh, 'plot_surface');
        
        qn = [V(:,i); zeros(ng, 1)];
        [ ~, idx] = max(abs(qn));
        qn = qn/qn(idx)*ps_max;
        
        if( flags.plot_fancy == 0 )
            plot_element_solution_hdsurf(ax, 1:ps_nel, 1, [0, 0, 1], ps_IEN, ID, ...
                ps_eltype, x, y, z, qn, ps_alpha, 0);
            
        elseif( flags.plot_fancy == 1 )
            plot_element_solution_hdsurf_coloredByDeformation(...
                ax, ps_IEN, ID, ps_eltype, x, y, z, qn, ...
                'field', 'displacement-z', ...
                'smoothing', 1, ...
                'alpha0', ps_alpha);
        end
        
        if( flags.plot_RestNodes == 1 )
            plot_node_solution(ax, A1, 'm' , 1, x, y, z, qn, ID);
            plot_node_solution(ax, A2, 'r' , 1, x, y, z, qn, ID);
            plot_node_solution(ax, A3, 'y' , 1, x, y, z, qn, ID);
            plot_node_solution(ax, A4, 'g' , 1, x, y, z, qn, ID);
        end
        
    end
    
end
