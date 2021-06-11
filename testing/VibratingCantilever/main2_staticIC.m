%% main2: static loading to get IC's

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
addpath(fullfile(ROOTDIR,'quadrature'));
addpath(fullfile(ROOTDIR,'shapefunctions'));
addpath(fullfile(ROOTDIR,'loadstepping'));

% std header
ned = 3;
std_element_defs;

%% Define parameters

% maximum displacement to move center of the tip to:
max_Z = 0.1;

% loading increment (negative or positive to pick direction)
DP   = 2e-5;


%% flags:
flags.verbose   = true;
flags.plot_steps_nskip = 4;
field_range = nan;
flags.plot_steps = 1;
flags.plot_fancy = 1;
flags.plot_colormap = 'default';

%% Locate the nodal info to track
% This is the displacement criteria to end the loop when max_Z is met:
[track_idx, track_A] = find_dof2track( x, y, z, ID, Fext_direction, A_Fext);

%% Init plot per step
qn = zeros(ndofs,1);
if flags.plot_steps > 0
    [fig, ax, hlist] = plot_static_steps_init(qn, x, y, z, ID, msh, flags, ...
        max_Z, track_A);
    
end


%% Load Stepping
fprintf('------------------------------------------\n')
if flags.verbose
    fprintf(' Step | Load     | iter | err    | time \n');
    fprintf('------------------------------------------\n')
end
Fext_load = 0;

stepping.complete = false;
stepping.iter = 0;
stepping.iterMax = 26;

while stepping.complete == false
    
    stepping.iter = stepping.iter + 1;
    
    %% increase the load
    Fext_load = Fext_load + DP;
    
    %% solve for new positions (tracing equilibrium here is a simple
    % continuation scheme)
    [qn, info] = loadStep_step(qn, Fext_load, Fext_direction, A_Fext, ...
        LM, ned, nen, nnp, nel, eltype, matype,...
        KK_idx_I, KK_idx_J,...
        E, x, y, z, IEN, ID, quad_rules, nu,...
        freefree_range, freefix_range, neq, gg, ...
        stepping.iter, flags.verbose);
    
    %% update step plot(s)
    if flags.plot_steps == 1 && mod(stepping.iter,flags.plot_steps_nskip) == 0
        hlist = plot_static_steps(ax, hlist, qn, x, y, z, ID, msh, ...
            flags, stepping.iter, ...
            Fext_load, field_range);
    end
    
    %% check for end of loop:
    if false
        
        
    elseif stepping.iter >= stepping.iterMax
       stepping.complete = -1; 
       
    end
    
end