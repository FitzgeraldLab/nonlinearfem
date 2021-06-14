%% main3:

clear variables
close all
clc

%% load preprocessed data
% load the mesh and properties
load('mesh.mat')
load('data.2021-06-14.10-42-46.mat')

path(pathdef)
ROOTDIR = fullfile('../..');
addpath(fullfile(ROOTDIR,'preprocmesh'));
addpath(fullfile(ROOTDIR,'assemble'));
addpath(fullfile(ROOTDIR,'postproc'));
addpath(fullfile(ROOTDIR,'shapefunctions'));
addpath(fullfile(ROOTDIR,'timemarching'));

% std header
ned = 3;
std_element_defs;

%% Define parameters

% Time integration stuff
N_t_steps = 10000;
iter.max_steps = 200;
iter.rel_tol = 1e-12;

% setup boundary motion
kineForcingFcn = @(t) boundaryMotion(t,[]);

% Plotting options
flags.plot_RestNodes = 1;
flags.plot_fancy = 1;
flags.plot_steps = 1;
flags.plot_steps_nskip = 1;
flags.plot_colormap = 'rwb';

% output options
flags.output.hdf5 = 0;

% check kill file
flags.checkKillFile = 1;

%% plot reference configuration
if flags.plot_steps > 0
    [fig, ax, hlist, est_max_disp] = plot_dynamic_steps_init(qn, x, y, z, ID, msh, ...
        flags);
    
end

%% build the initial conditions:
q0 = qn;
qd0= zeros(size(q0));

K1 = K(freefree_range, freefree_range);
M1 = M(freefree_range, freefree_range);
D1 = D(freefree_range, freefree_range);

%% Initialize Generalized Alpha Method
minT = 2*pi/sqrt(eigs(K1,M1,1,'lm'));
maxT = 2*pi/sqrt(eigs(K1,M1,1,'sm'));
T_list = real(2*pi./sqrt(eigs(K1,M1,100,'sm')));

%dt = T_list(6)/10; % 10 points in time for the 6th mode
dt = 20*minT;

% setup gen-alpha parameters
rho_inf = 0.9;

% setup containers
qn   = q0;
qdn  = qd0;
qddn = zeros(ndofs,1);

A_kineForcing = A_BC;

%%
% start the time march
fprintf(1,'----------------------\n');
fprintf(1,'Time Step:\n');
t = 0;
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
        hlist = plot_dynamic_steps(ax, hlist, qn, t, x, y, z, ID, msh, flags, ...
            n, [-1,1]*1.1*est_max_disp);
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
if flags.checkKillFile
    checkKillFile('remove', 1);
end

