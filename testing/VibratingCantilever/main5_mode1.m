% main5: mode-1

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
flags.plot_colormap = 'parula'; % {default,parula}, {Div}
flags.mov.mp4 = 1;
flags.mov.comment = 'temp';


%%
path(pathdef)
ROOTDIR = fullfile('../..');
addpath(fullfile(ROOTDIR,'preprocmesh'));
addpath(fullfile(ROOTDIR,'postproc'));
addpath(fullfile(ROOTDIR,'shapefunctions'));

% std header
ned = 3;
std_element_defs;

%%
[v,d] = eigs(K(freefree_range,freefree_range),...
    M(freefree_range,freefree_range), 5, 'sm');

%%
q0 = [v(:,1);zeros(ng,1)];


% plot the initial conditions
ps_alpha = 0.5;
fig = figure();
ax = axes('Parent', fig, 'DataAspectRatio', [1, 1, 1]);
hold(ax, 'on');
xlabel(ax,'x');
ylabel(ax,'y');
zlabel(ax,'z');
grid(ax,'on');
view(ax, [40,16]);

% xlim(ax, [min(x),max(x)]*1.1);
% ylim(ax, [min(y),max(y)]*1.1);

max_disp = max([abs(min(z) + min(q0)),max(z)+max(q0)]);
est_max_disp = max_disp;

% zlim(ax, [-1,1]*1.2*max_disp );

%%
colorbar(ax);

%% Colormap
if any( strcmpi( flags.plot_colormap, {'','default', 'parula'}) )
    colormap(ax,parula);
elseif any( strcmpi( flags.plot_colormap, {'divergent','rwb'}) )
    colormap(ax,colorcet('D1A'));
else
    error('Colormap unknown: <%s>\n',flags.plot_colormap)
end


%%
[ps_nel, ps_eltype, ps_IEN] = parse_msh( msh, 'plot_surface');

%%
if flags.plot_fancy == 0
    hlist = plot_element_solution_hdsurf(ax, 1:ps_nel, 1, ...
        [0, 0, 1], ps_IEN, ID, ps_eltype, x, y, z, q0, ...
        ps_alpha, 0);
    
elseif flags.plot_fancy == 1
    hlist = plot_element_solution_hdsurf_coloredByDeformation(...
        ax, ps_IEN, ID, ps_eltype, x, y, z, q0, ...
        'field', 'displacement-norm2', ...
        'smoothing', 1, ...
        'alpha0', ps_alpha);
end

%%
V = v(:,1:2);

% working dir
flags.working.dir = 'temp';

flags.n.start = 1;
flags.n.end   = 10000;
flags.n.skip  = 2;

N = flags.n.start : flags.n.skip : flags.n.end;
alpha = zeros(length(N),size(V,2));
beta = zeros(length(N), 1);
i = 0;
time = zeros(length(N),1);
for n = N
    i = i+1;
    %% Load the data
    data = load(fullfile(flags.working.dir, sprintf('ga.%08d.mat', n) ),...
        'qn', 't');
    
    alpha(i,:) = V'*data.qn(1:neq);
    beta(i) = norm(alpha(i,1:2));
    time(i) = data.t;
    
end


figure
plot( time, alpha)
