function hlist = plot_node_labels(axes_handle, GlobalNodeList, x, y, z,...
    varargin)

%% Parse input
p = inputParser;
addRequired( p,    'axes_handle', @simple_axes_check);
addRequired( p, 'GlobalNodeList', @isnumeric);
addRequired( p,           'x', @isnumeric);
addRequired( p,           'y', @isnumeric);
addRequired( p,           'z', @isnumeric);

addParameter(p,       'field',      'number',  @ischar);
addParameter(p,    'fontsize',            10, @isnumeric);
addParameter(p,   'fontcolor',           [0.8500,0.3250,0.0980]);
addParameter(p,   'fontweight',       'bold', @ischar);
addParameter(p,'backgroundcolor',     'none');

% Parse the inputs
parse(p, axes_handle, GlobalNodeList, x, y, z, varargin{:});

flag_field     = p.Results.field;
fontsize       = p.Results.fontsize;
fontcolor      = p.Results.fontcolor;
fontweight     = p.Results.fontweight;
backgroundcolor= p.Results.backgroundcolor;


%% work by element, placing the label at the center
hlist = nan(size(GlobalNodeList));

i = 0;
for A = GlobalNodeList
    i = i+1;
        
    xe = x(A);
    ye = y(A);
    ze = z(A);
    
    if( strcmpi(flag_field, 'number') )
        el_str = sprintf('%d', A);
               
    else
        error('label type <%s> not implemented', flag_field);
    end
    
    hlist(i) = text(xe, ye, ze, el_str, ...
        'FontSize', fontsize, ...
        'Color', fontcolor, ...
        'BackgroundColor', backgroundcolor, ...
        'FontWeight', fontweight, ...
        'HorizontalAlignment', 'center', ...
        'Parent', axes_handle);
    
end
