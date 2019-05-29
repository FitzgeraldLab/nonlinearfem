function h = plot_InertiaAxes(ax, body_COM, body_inertia, varargin)

%%
p = inputParser;
addRequired(p, 'ax', @simple_axes_check);
addRequired(p, 'body_COM', @(x) all([isnumeric(x), numel(x) == 3]));
addRequired(p, 'body_inertia', @(x) all([isnumeric(x), all(size(x) == [3,3])]));

addParameter(p, 'color_list', {'r', 'g', 'b'});
addParameter(p,      'scale', 1.0, @isnumeric);
addParameter(p,  'linewidth', 2.0, @isnumeric);

parse(p, ax, body_COM, body_inertia, varargin{:});
color_list = p.Results.color_list;
scale      = p.Results.scale;
linewidth  = p.Results.linewidth;

%% determine the prin. directions
[V,~] = eig(body_inertia);

%% plot the axes
h = nan(1,3);
for j = 1:3
    v = scale*V(:,j)/norm(V(:,j),2);
    h(j) = quiver3(ax, body_COM(1), body_COM(2), body_COM(3), v(1), v(2), v(3), 0, ...
        'color', color_list{j}, ...
        'linewidth', linewidth);
end

