%% Preprocess
% Prepare the hdf5 file used in the fortran code

%%
clear all ; close all ; clc
addpath('../../preprocmesh')

%% Define Master Parameters

%dir_in = pwd;
dir_in = './';
dir_out = dir_in;

% GMSH file:
geofile = fullfile(dir_in,'plate.1.msh');

% hdf5 output file:
flag_writeoutput = 1;
hfile = fullfile(dir_out,'sm_body.1.h5');

% Constant Material Properties for an isotropic material
E        = 3.539664277994649e+004; % so that T_1 = 1
nu       = 0.3 ; %[]
grav_vec = 9.8065*[0; -1; 0]; %[m/s^2];
grav_flag= 0; % turn on gravity?
rho      = 1; %

% Period of the first natural frequency
T1 = 2/3;
% Angle of attack
rot_alpha = 15*pi/180;

% Damping parameters % [D] = alpha*[M] + beta*[K0]
damping.flag  = 0;
damping.alpha = 0;
damping.beta  = 3.580947556138772e-004;

% set which material model to use
%   Krichoff = 1; Biot = 2
matype = 2;

DOFS_per_node = 3;

% Newton-Raphson Method Parameters:
epsilon = 1e-6;
maxiter = 20;

% time marching parameters (not used in FLASH)
dt        = 0.01;
N_t_steps = 200;

% time marching stuff that is updated in the hdf5
rho_inf   = 0.8;
Nmode = 10;

% Important
dyn_IC_flag = 2; % 0: 0 IC's, 1 load IC's, 2 set IC's to match v(0)
kinematics_idx = 5; % 1: Berman Wang, 2: fixed, ...?

% BodyType:
% 1= Rigid
% 2= 2D Flexible
% 3= 3D Flexible
% 4= RBC
BodyType = 3;

% IntegMethod
% 1=GenAlpha Pred-Corr, 2=Adams Pred-Corr
IntegMethod = 1;

comments = 'Rigid Plate that Osc.';

options = options_struct(1,1);
auto_update_body_parameters = 1;

%% Start the diary
logname = fullfile(dir_out,'preproc.log');
if( exist(logname,'file') == 2 )
    delete(logname);
end
diary(logname);

%% Make the mesh
preproc2fort_csc_background(geofile,...
    hfile, flag_writeoutput, E, nu, grav_vec, grav_flag, rho, matype, ...
    DOFS_per_node, epsilon, maxiter, dt,N_t_steps, rho_inf, ...
    dyn_IC_flag, kinematics_idx, comments, BodyType, damping, options,IntegMethod);

%% Automatic Mesh Analysis Stuff
if( auto_update_body_parameters == 1 )
    
    fprintf(1,'**********************************************\n');
    fprintf(1,'* Updating body parameters automatically     *\n');
    fprintf(1,'**********************************************\n');
    
    addpath('../../postproc')
    addpath('../../assemble')
    addpath('../../mesh_analysis')
    
    %% Rotate the reference frame
    flag_update_hdf5 = 1;
    flag_plot = 0;
    rotate_ref_config(hfile,rot_alpha,flag_update_hdf5, flag_plot);
    
    %% Update Young's Modulus
    flag_update_hdf5 = 1;
    Update_YoungsModulus(hfile, T1, flag_update_hdf5);
    
    %% Update the Prop. Damping
    zeta_max = 1;
    flag_update_hdf5 = 1;
    flag_plot = 0;
    Update_PropDamping(hfile, zeta_max, flag_update_hdf5, flag_plot);
    
    %% update rho_inf and approx dt
    flag_update_hdf5 = 1;
    Update_GenAlpha_rhoInf(hfile, Nmode, rho_inf, flag_update_hdf5);
    
end

%%
path(pathdef)
diary off