%% main_fem


%%
clear all;
close all
clc

%% Define parameters
E0   = 1;
nu0  = 0.3;
rho0 = 1;

Lx = 1;
Ly = 1;
Lz = 0.05;

Nx_list = 1:10;
Ny_list = 1:10;
Nz_list = 1:2;

BC_x0 = 'S';
BC_xL = 'S';
BC_y0 = 'S';
BC_yL = 'S';

matype0 = 1;
n_eigenvalues = 5;

flag.output_natfreq = 1;

%% Set lesser used options

ROOTDIR = fullfile('../..');
gmsh_exe = 'c:\Users\tim\Downloads\gmsh-2.8.5-Windows\gmsh.exe';
path(pathdef)
addpath(fullfile(ROOTDIR,'preprocmesh'));
addpath(fullfile(ROOTDIR,'assemble'));
addpath(fullfile(ROOTDIR,'postproc'));

% std header
ned = 3;
std_element_defs;

% generate or load gaussian quadrature information
quad = gauss_quad_rules( 'prod', 5, 3);

%% Prep the output file
if( flag.output_natfreq == 1 )

    fid = fopen( sprintf('natfreq_Lx=%.2f_Ly=%.2f_Lz=%.2f_%s%s%s%s.dat',...
        Lx, Ly, Lz, BC_x0, BC_xL, BC_y0, BC_yL), 'w');
    
    if( fid < 2 )
        error('Cannot start file writing');
    end

end

%% Loop over Element list
tempfile = 'temp';
for nel_x = Nx_list
    for nel_y = Ny_list
        for nel_z = Nz_list
            
            
            %% Make a new FEM mesh
            if( gen_plate_geo( Lx, Ly, Lz, nel_x, nel_y, nel_z, [tempfile,'.geo']) ~= 0 )
                error('Cannot make geo file...');
            end
            
            cmd = sprintf('%s -3 %s', gmsh_exe, [tempfile,'.geo']);
            if( system(cmd) ~= 0 )
                error('Cannot GMSH the geo file');
            end
            
            %% Load the msh into matlab
            [Nodes, msh, ~] = load_gmsh([tempfile,'.msh']);
            
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
            
            %% set which material model to use
            %   Krichoff = 1; Biot = 2
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
            fix = apply_BC2face(msh, x, y, z, fix, 'face4', BC_x0);
            
            % BC's for X = Lx
            fix = apply_BC2face(msh, x, y, z, fix, 'face2', BC_xL);
                        
            % BC's for Y = 0
            fix = apply_BC2face(msh, x, y, z, fix, 'face1', BC_y0);
            
            % BC's for Y = Ly
            fix = apply_BC2face(msh, x, y, z, fix, 'face3', BC_yL);
                  
            %% Construct the IM and LM Matricies
            [ID, LM, neq, gg, nee, ng, r1] = build_mesh(...
                nnp, IEN, g_list, nen, ned, nel, eltype, fix);
            
            %% build Mass and Stiffness Matrices
            ndofs = neq+ng;
            qi = zeros(ndofs,1);
            
            % Build index for fast assembly
            [KK_idx_I,KK_idx_J] = get_nnz_CheckAssembly(LM, nen, nel, eltype);

            % Build M
            [M] = assemble_M(IEN, ned, nen, nnp, nel, ...
                x, y, z, rho, eltype, quad, ...
                KK_idx_I, KK_idx_J);
            M = M(r1,r1);
            
            % Build K
            [K,~] = assemble_K(IEN, ID, LM, ned, nen, nnp, nel, ...
                x, y, z, E, nu, qi, eltype, matype, quad, ...
                KK_idx_I, KK_idx_J);
            K = K(r1,r1);

            %% Compute the first several eigenvalues
            [V, D]= eigs(K,M,n_eigenvalues,'sm');
            [omega, idx] = sort( sqrt(diag(D)) );
            V = V(:,idx);
            
            fprintf(fid, 'nel_x =%3d, nel_y =%3d, nel_z =%3d: ', nel_x, nel_y, nel_z);
            for i = 1:n_eigenvalues
                fprintf( fid, '%20.9e ', omega(i));
            end
            fprintf(fid, '\b\n');
            
        end
    end
end

%%
if( flag.output_natfreq == 1 )

    fid = fclose(fid);

end

