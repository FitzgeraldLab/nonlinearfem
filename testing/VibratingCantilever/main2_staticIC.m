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
addpath(fullfile(ROOTDIR,'shapefunctions'));
addpath(fullfile(ROOTDIR,'loadstepping'));

% std header
ned = 3;
std_element_defs;

%% Define parameters

% maximum displacement to move center of the tip to:
max_Z = 0.1;

% loading increment (negative or positive to pick direction)
DP   = 5e-4;


%% flags:
flags.verbose   = true;
flags.plot_steps_nskip = 10;
field_range = [0,max_Z*1.2];
flags.plot_steps = 1;
flags.plot_fancy = 1;
flags.plot_colormap = 'default';
flags.plot_trackPt = 1;

%% Locate the nodal info to track
% This is the displacement criteria to end the loop when max_Z is met:
[track_idx, track_A] = find_dof2track( x, y, z, ID, Fext_direction, A_Fext);

%% Init plot per step
qn = zeros(ndofs,1);
if flags.plot_steps > 0
    [fig, ax, hlist] = plot_static_steps_init(qn, x, y, z, ID, msh, flags, ...
        max_Z, track_A);
    pause(0.01);
end


%% Load Stepping
fprintf('------------------------------------------\n')
if flags.verbose
    fprintf(' Step | Load     | iter | err    | time \n');
    fprintf('------------------------------------------\n')
end
Fext_load0 = 0;

stepping.complete = false;
stepping.iter = 0;
stepping.iterMax = 5000;

while stepping.complete == false
    
    stepping.iter = stepping.iter + 1;
    
    %% increase the load
    Fext_load1 = Fext_load0 + DP;
    
    %% solve for new positions (tracing equilibrium here is a simple
    % continuation scheme)
    [qn, info] = loadStep_step(qn, Fext_load1, Fext_direction, A_Fext, ...
        LM, ned, nen, nnp, nel, eltype, matype,...
        KK_idx_I, KK_idx_J,...
        E, x, y, z, IEN, ID, quad_rules, nu,...
        freefree_range, freefix_range, neq, gg, ...
        stepping.iter, flags.verbose);
    
    %% update step plot(s)
    if flags.plot_steps == 1 && mod(stepping.iter,flags.plot_steps_nskip) == 0
        hlist = plot_static_steps(ax, hlist, qn, x, y, z, ID, msh, ...
            flags, stepping.iter, ...
            Fext_load1, field_range, track_A, track_idx);
    end
    
    %% check for end of loop:
    qX1 = qn(track_idx);
    
    if qX1 >= max_Z
        
        stepping.complete = 1;
        
        
    elseif stepping.iter >= stepping.iterMax
       stepping.complete = -1; 
       
    else
        
        qX0 = qX1;
        Fext_load0 = Fext_load1;
       
    end
    
end

%% Method of False Position:
fprintf('------------------------------------------\n')
if flags.verbose
    fprintf(' Step | Load     | iter | err    | time \n');
    fprintf('------------------------------------------\n')
end

stepping.complete = false;
stepping.iter = 0;
stepping.iterMax = 500;
stepping.tol = 1e-3;


fx0 = qX0 - max_Z;
while stepping.complete == false
    
    stepping.iter = stepping.iter + 1;
    
    %% Method of false position
    fx1 = qX1 - max_Z;
    Fext_load1 = Fext_load0 - (Fext_load1 - Fext_load0)/( fx1 - fx0 )*fx0;
    
    
    %% solve for new positions (tracing equilibrium here is a simple
    % continuation scheme)
    [qn, info] = loadStep_step(qn, Fext_load1, Fext_direction, A_Fext, ...
        LM, ned, nen, nnp, nel, eltype, matype,...
        KK_idx_I, KK_idx_J,...
        E, x, y, z, IEN, ID, quad_rules, nu,...
        freefree_range, freefix_range, neq, gg, ...
        stepping.iter, flags.verbose);
    
    %% update step plot(s)
    if flags.plot_steps == 1 && mod(stepping.iter,flags.plot_steps_nskip) == 0
        hlist = plot_static_steps(ax, hlist, qn, x, y, z, ID, msh, ...
            flags, stepping.iter, ...
            Fext_load1, field_range, track_A, track_idx);
    end
    
    %% check for end of loop:
    qX1 = qn(track_idx);
     
    
    if norm(qX1 - max_Z) <= stepping.tol
        
        stepping.complete = 1;
        
        
    elseif stepping.iter >= stepping.iterMax
       stepping.complete = -1; 
             
    end
    
end

Fext_load = Fext_load1;

%% update step plot(s)
if flags.plot_steps == 1
    hlist = plot_static_steps(ax, hlist, qn, x, y, z, ID, msh, ...
        flags, stepping.iter, ...
        Fext_load1, field_range, track_A, track_idx);
end

%% Save the output:
outfile_datestr = datestr(now,'yyyy-mm-dd.HH-MM-SS');
outfilename     = sprintf('data.%s.mat', outfile_datestr );
save(outfilename, 'qn', 'Fext_load', 'stepping', 'info')
