%% Make some plots

clear all
close all
clc


%%
infiletag = '2020-05-21.21-04-22';

comment = 'skip1';

load(['data.',infiletag, '.mat']);
hfile = ['data.',infiletag, '.h5'];

% options:
flags.plot_ref = 1;


%% plot reference configuration
if flags.plot_ref > 0 
    plot_ref(Lx, Ly, x, y, z, ID, neq, ng, msh, flags, A_Fext, A_BC);
end

%% Track node
% I'll pick the node at the geometric center of the beam
A1 = find( abs(x - Lx/2) < 1e-6 );
A2 = find( abs( y(A1) - Ly/2 ) < 1e-6) ;
A3 = find( abs( z(A1(A2)) - 0 ) < 1e-6 );
A_ctr = A1(A2(A3));

%%
n_skip = 1;

% Plotting options
flags.plot_fancy = 1;
flags.plot_marks = 1;
flags.plot_restraints = 1;
flags.plot_colormap = 'parula'; % {default,parula}, {Div}, rwb


%%
ROOTDIR = fullfile('../..');
path(pathdef)
addpath(fullfile(ROOTDIR,'preprocmesh'));
addpath(fullfile(ROOTDIR,'postproc'));
addpath(fullfile(ROOTDIR,'shapefunctions'));

%% Search through field for color scaling
N_to_sample = ceil( 0.25*N_load_endstep);
n_list = sort([1, randi([2,N_load_endstep], [1, N_to_sample])]);
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


%% Load and plot
for n = 1:n_skip:N_load_endstep
    
    progressbarText(n/N_t_endstep);
   
    
    %% Load the data
    Fext_load = h5read( hfile, sprintf('/%d/load', n) );
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