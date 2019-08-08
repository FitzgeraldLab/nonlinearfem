function hlist = plot_node_solution(axes_handle, ID, x, y, z, qn, varargin)

%A_in=nnp= total number of nodes
%qn=qi= states of the nodes
%x: local position of the nodes?
% ID+[x y z]=global positino?
%% Parse input
p = inputParser;
addRequired( p, 'axes_handle', @simple_axes_check);
addRequired( p,          'ID', @isnumeric);
addRequired( p,           'x', @isnumeric);
addRequired( p,           'y', @isnumeric);
addRequired( p,           'z', @isnumeric);
addRequired( p,          'qn', @isnumeric);

addParameter(p,        'A_in',  1:size(ID,2), @isnumeric);
addParameter(p, 'scalefactor',             1, @isnumeric);
addParameter(p,      'marker',           '*', @ischar);
addParameter(p, 'markercolor',           'r');
addParameter(p,  'markersize',             6, @isnumeric); 


% Parse the inputs
parse(p, axes_handle, ID, x, y, z, qn, varargin{:});

A_in           = p.Results.A_in;      % =nnp
scalefactor    = p.Results.scalefactor;
marker         = p.Results.marker;
markercolor    = p.Results.markercolor;
markersize     = p.Results.markersize;


%%
hlist = zeros(1,length(A_in));
for a = 1:length(A_in)
    A = A_in(a);
    
    P = ID(1,A);
    xo = scalefactor*qn(P) + x(A);
    
    P = ID(2,A);
    yo = scalefactor*qn(P) + y(A);
    
    P = ID(3,A);
    zo = scalefactor*qn(P) + z(A);
    
    hlist(a) = ...
        plot3(axes_handle, xo, yo, zo, 'linestyle','none',...
        'Marker', marker,...
        'MarkerSize', markersize,...
        'Color', markercolor,...
        'MarkerFaceColor', markercolor,...
        'MarkerEdgeColor', markercolor);
end