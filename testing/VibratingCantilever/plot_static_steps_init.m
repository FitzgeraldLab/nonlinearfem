function [fig, ax, hlist] = plot_static_steps_init(q0, x, y, z, ID, msh, ...
    flags, max_Z, track_A)

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

xlim(ax, [min(x),max(x)]*1.1);
ylim(ax, [min(y),max(y)]*1.1);
zlim(ax, [min(z)*1.1, max_Z*1.3]);


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
        'field', 'displacement-z', ...
        'smoothing', 1, ...
        'alpha0', ps_alpha);
end


%%
temp = plot_node_solution(ax, ID, x, y, z, q0, 'A_in', track_A, ...
        'markercolor', [0.8500, 0.3250, 0.0980], 'marker', 'o');
    
hlist = [hlist, temp];

