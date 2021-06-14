function [fig, ax, hlist] = plot_dynamic_steps_init(q0, x, y, z, ID, msh, ...
    flags)

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

max_disp = max([abs(min(z) + min(q0)),max(z)+max(q0)]);

zlim(ax, [-1,1]*1.2*max_disp );

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
        'alpha0', ps_alpha,...
        'field_range', [-1,1]*max_disp);
end

