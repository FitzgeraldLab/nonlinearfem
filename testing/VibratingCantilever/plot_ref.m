function [fig, ax] = plot_ref(Lx, Ly, x, y, z, ID, neq, ng, msh, flags, A_Fext, A_BC)

fig = figure();
ax = axes('Parent',fig,'DataAspectRatio',[1 1 1]);

hold(ax, 'on');
xlabel(ax,'x');
ylabel(ax,'y');
zlabel(ax,'z');
grid(ax,'on');

xlim(ax, Lx*[-0.05, 1.05])
ylim(ax, Ly*[-1.05, 1.05])

title(ax, 'Reference plot' );

%%
[ps_nel, ps_eltype, ps_IEN] = parse_msh( msh, 'plot_surface');


%%
qn = zeros(neq+ng, 1);
%plot_element(ax,1:ps_nel,'g', ps_IEN, ps_eltype, x, y, z);
plot_element_solution_hdsurf2(ax, 1:ps_nel, ps_IEN, ID, ps_eltype, ...
    x, y, z, qn,...
    'surf_alpha', 0.1);


%%
plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A_Fext, ...
    'markercolor', 'r');

if flags.plot_RestNodes == 1
    plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A_Fext, ...
        'markercolor', 'r');
    
    plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A_BC, ...
        'markercolor', 'b', 'marker', 'o');
end

if( flags.plot_ref == 2 )
    % for debugging, stop the script here once the ref has been plotted
    fprintf('\n...paused...\n');
    pause()
end
