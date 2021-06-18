%% Visualize the dynamic results

clear variables
close all
clc


%% load preprocessed data
% load the mesh and properties
load('mesh.mat')
load('data.2021-06-14.10-42-46.mat')

% working dir
flags.working.dir = 'temp';

flags.n.start = 1;
flags.n.end   = 10000;
flags.n.skip  = 2;


% Plotting options
flags.plot_fancy = 1;
flags.plot_restraints = 0;
flags.plot_colormap = 'rwb'; % {default,parula}, {Div}
flags.mov.mp4 = 1;
flags.mov.comment = 'temp';


%%
path(pathdef)
ROOTDIR = fullfile('../..');
addpath(fullfile(ROOTDIR,'preprocmesh'));
addpath(fullfile(ROOTDIR,'postproc'));
addpath(fullfile(ROOTDIR,'shapefunctions'));


%% plot reference configuration
[fig, ax, hlist, est_max_disp] = plot_dynamic_steps_init(qn, x, y, z, ID, msh, ...
        flags);
   
set(fig,'color','w','units', 'normalized');
set(fig, 'outerposition', [0.1 0.1 0.8 0.8 ]);
    
%% init movie
if flags.mov.mp4
    mov_name = sprintf('animation.%s', flags.mov.comment );
    V = VideoWriter( mov_name, 'Motion JPEG AVI');
    %fps = nframes/tf;
    fps = 30;
    V.FrameRate = fps;
    open(V);
end

% progressbarText(0);

%% Load and plot
N = flags.n.start : flags.n.skip : flags.n.end;
for n = N
    
%     progressbarText(n/( N(end) - N(1)));
   
    
    %% Load the data
    data = load(fullfile(flags.working.dir, sprintf('ga.%08d.mat', n) ),...
        'qn', 't');
    
    %% update the plot
    hlist = plot_dynamic_steps(ax, hlist, data.qn, data.t, x, y, z, ...
        ID, msh, flags, n, [-1,1]*1.1*est_max_disp );
    
    %%
%     if flags.plot_restraints
%         h1 = plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A_kineForcing, 'markercolor', [0,0.4,0.1]);
%         hlist = [h1,hlist];
%     end
%     
    %%
%     title(sprintf('n=%5d, t= %5.2e', n, t) );
    
    pause(0.01);
    
    if flags.mov.mp4     
        drawnow
        writeVideo( V, getframe(ax) );
    end
    
end

% close the movie file
if flags.mov.mp4
    close(V);
end