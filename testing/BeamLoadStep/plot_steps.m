function hlist = plot_steps(ax, hlist, qn, x, y, z, ID, msh, flags, n, load)

ps_alpha = 0.5;

delete(hlist);
[ps_nel, ps_eltype, ps_IEN] = parse_msh( msh, 'plot_surface');

if flags.plot_fancy == 0
    hlist = plot_element_solution_hdsurf(ax, 1:ps_nel, 1, ...
        [0, 0, 1], ps_IEN, ID, ps_eltype, x, y, z, qn, ...
        ps_alpha, 0);
    
elseif flags.plot_fancy == 1
    hlist = plot_element_solution_hdsurf_coloredByDeformation(...
        ax, ps_IEN, ID, ps_eltype, x, y, z, qn, ...
        'field', 'displacement-z', ...
        'smoothing', 1, ...
        'alpha0', ps_alpha,...
        'scalefactor', 1);
end

title(sprintf('n=%5d, load=%6.2f', n, load) );

pause(0.01);