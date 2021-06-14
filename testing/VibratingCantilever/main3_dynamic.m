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
flags.plot_ref = 1;
flags.plot_RestNodes = 1;
flags.plot_fancy = 1;
flags.plot_q0 = 1;
flags.plot_steps = 1;
flags.plot_steps_nskip = 10;
flags.plot_colormap = 'rwb';

% output options
flags.output.hdf5 = 1;

% check kill file
flags.checkKillFile = 1;

%% plot reference configuration
if flags.plot_ref > 0 
[fig, ax, hlist] = plot_dynamic_steps_init(qn, x, y, z, ID, msh, ...
    flags);

end