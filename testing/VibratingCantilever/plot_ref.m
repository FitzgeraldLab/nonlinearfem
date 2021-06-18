function [fig, ax, hlist] = plot_ref(x, y, z, ID, neq, ng, msh, flags, A_Fext, A_BC)

fig = figure();
ax = axes('Parent',fig,'DataAspectRatio',[1 1 1]);

hold(ax, 'on');
xlabel(ax,'x');
ylabel(ax,'y');
zlabel(ax,'z');
grid(ax,'on');


xlim(ax, [min(x), max(x)]*1.05)
ylim(ax, [min(y), max(y)]*1.05)

title(ax, 'Reference plot' );

%%
[ps_nel, ps_eltype, ps_IEN] = parse_msh( msh, 'plot_surface');


%%
qn = zeros(neq+ng, 1);
%plot_element(ax,1:ps_nel,'g', ps_IEN, ps_eltype, x, y, z);
hlist = plot_element_solution_hdsurf2(ax, 1:ps_nel, ps_IEN, ID, ps_eltype, ...
    x, y, z, qn,...
    'surf_alpha', 0.1);


%%
temp = plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A_Fext, ...
    'markercolor', 'r');

hlist = [hlist, temp];

if flags.plot_RestNodes == 1
    hlist = plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A_Fext, ...
        'markercolor', 'r');
    hlist = [hlist, temp];
    
    hlist = plot_node_solution(ax, ID, x, y, z, qn, 'A_in', A_BC, ...
        'markercolor', 'b', 'marker', 'o');
    hlist = [hlist, temp];
end

if( flags.plot_ref == 2 )
    % for debugging, stop the script here once the ref has been plotted
    fprintf('\n...paused...\n');
    pause()
end
