function [fig, ax] = init_plot_figure(varargin)

%% parse the inputs
p = inputParser;
addParameter(p, 'view', NaN);
addParameter(p, 'xlim', NaN);
addParameter(p, 'ylim', NaN);
addParameter(p, 'zlim', NaN);
addParameter(p, 'grid', 'on');

% Parse the inputs
parse(p, varargin{:});
set_view = p.Results.view;
set_xlim = p.Results.xlim;
set_ylim = p.Results.ylim;
set_zlim = p.Results.zlim;
set_grid = p.Results.grid;

%% Init the plot
fig = figure();
ax = axes('Parent', fig);
hold(ax,'on');
set(ax, 'DataAspectRatio', [1,1,1]);
xlabel(ax,'x');
ylabel(ax,'y');
zlabel(ax,'z');

%% turn on the grid
grid(ax, set_grid);

%% set the view
if( all(~isnan(set_view)) && ~isempty(set_view) )
    view(ax, set_view);
end

%% set the xlim
if( all(~isnan(set_xlim)) && ~isempty(set_xlim) )
    xlim(ax, set_xlim);
end

%% set the ylim
if( all(~isnan(set_ylim)) && ~isempty(set_ylim) )
    ylim(ax, set_ylim);
end

%% set the zlim
if( all(~isnan(set_zlim)) && ~isempty(set_zlim) )
    zlim(ax, set_zlim);
end



