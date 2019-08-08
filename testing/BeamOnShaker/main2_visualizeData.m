%%

clear all
close all
clc


%%
% infiletag = '17-Jul-2019 14:34:14';
infiletag = '26-Jul-2019 14:58:09';

comment = 'skip1';

load(['data.',infiletag, '.mat']);
hfile = ['data.',infiletag, '.h5'];

% Tracking nodes
A_list = [ 6, 3, 30, 96 ];

dt_skip = 1;

% Plotting options
flags.plot_fancy = 1;
flags.plot_marks = 1;
flags.plot_restraints = 1;
flags.plot_colormap = 'rwb'; % {default,parula}, {Div}
flags.mov.mp4 = 1;


%%
ROOTDIR = fullfile('../..');
path(pathdef)
addpath(fullfile(ROOTDIR,'preprocmesh'));
% addpath(fullfile(ROOTDIR,'assemble'));
addpath(fullfile(ROOTDIR,'postproc'));
% addpath(fullfile(ROOTDIR,'quadrature'));
addpath(fullfile(ROOTDIR,'shapefunctions'));

%% Search through field for color scaling
N_to_sample = ceil( 0.25*N_t_endstep );
n_list = sort([1, randi([2,N_t_endstep], [1, N_to_sample])]);
max_info = findMaxDisp(hfile, ID, n_list);


%%
% plot the initial conditions
ps_alpha = 0.5;

fig = figure('color','w',...
    'units', 'normalized');

set(fig, 'outerposition', [0.1 0.1 0.8 0.8 ]);


ax = axes('Parent', fig, 'DataAspectRatio', [1, 1, 1]);
hold(ax, 'on');
xlabel(ax,'x');
ylabel(ax,'y');
zlabel(ax,'z');
grid(ax,'on');
view(ax, [40,16]);

xlim(ax, [-0.1,1]*1.2*Lx);
ylim(ax, [-0.1,1.1]*Ly);

% zlim(ax, [floor(max_info.min.val(3)), ceil(max_info.max.val(3))] );
%zlim(ax, [1.2*max_info.min.val(3), 1.2*max_info.max.val(3)] );
zlim(ax,[-1,1]*0.25);

if any( strcmpi( flags.plot_colormap, {'','default', 'parula'}) )
    colormap(ax,parula);
elseif any( strcmpi( flags.plot_colormap, {'divergent','rwb'}) )
    colormap(ax,colorcet('D1A'));
else
    error('Colormap unknown: <%s>\n',flags.plot_colormap)
end


%%

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

%% init movie
if flags.mov.mp4
    mov_name = sprintf('animation.%s.%s', infiletag, comment );
    V = VideoWriter( mov_name, 'Motion JPEG AVI');
    %fps = nframes/tf;
    fps = 30;
    V.FrameRate = fps;
    open(V);
end

progressbarText(0);

%% Load and plot
for n = 1:dt_skip:N_t_endstep
    
    progressbarText(n/N_t_endstep);
   
    
    %% Load the data
    t = h5read( hfile, sprintf('/%d/t', n) );
    qn = h5read( hfile, sprintf('/%d/qn', n) );
    
    
    %% update the plot
    delete(hlist);
    if flags.plot_fancy == 0
        hlist = plot_element_solution_hdsurf(ax, 1:ps_nel, 1, [0, 0, 1], ps_IEN, ID, ...
            ps_eltype, x, y, z, qn, ps_alpha, 0);
        
    elseif flags.plot_fancy == 1
        hlist = plot_element_solution_hdsurf_coloredByDeformation(...
            ax, ps_IEN, ID, ps_eltype, x, y, z, qn, ...
            'field', 'displacement-z', ...
            ...%'field', 'displacement-norm2',...
            ...%'field_range', [-1,1]*5*Lz,...
            'field_range', max_info.box.symmetric(3)*[-1,1],...
            'smoothing', 1, ...
            'alpha0', ps_alpha,...
            'scalefactor', 1);
    end
    
    %%
    if flags.plot_marks

        h1 = plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A_list, 'marker', 'o', 'markersize', 10);
        hlist = [h1,hlist];
        
    end
    
    %%
    if flags.plot_restraints
        h1 = plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A_kineForcing, 'markercolor', [0,0.4,0.1]);
        hlist = [h1,hlist];
    end
    
    %%
    title(sprintf('n=%5d, t= %5.2e', n, t) );
    
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