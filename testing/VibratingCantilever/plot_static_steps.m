function hlist = plot_static_steps(ax, hlist, qn, x, y, z, ID, msh, flags, ...
    n, load, field_range, track_A, track_idx)

ps_alpha = 0.5;

%% clear the sheet:
delete(hlist);

%%
[ps_nel, ps_eltype, ps_IEN] = parse_msh( msh, 'plot_surface');

%%
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
        'scalefactor', 1, ...
        'field_range', field_range);
end

%% add tracking point
if flags.plot_trackPt == 1
    
    temp = plot_node_solution(ax, ID, x, y, z, qn, 'A_in', track_A, ...
        'markercolor', [0.8500, 0.3250, 0.0980], 'marker', 'o');
    
    hlist = [hlist, temp];
    
end


%% Update the title
title(sprintf('n=%5d, load=%-8.2e, dof=%3.1e', n, load, qn(track_idx)) );

%% flush the buffer
pause(0.01);