function hlist = plot_element_solution_localpts(axes_handle, e_in, IEN, ID, eltype, x, y, z, qn, Xi, varargin)


%% Required inputs
p = inputParser;
addRequired(p, 'axes_handle', @simple_axes_check);
addRequired(p, 'e_in', @isnumeric);
addRequired(p, 'IEN', @isnumeric);
addRequired(p, 'ID', @isnumeric);
addRequired(p, 'eltype', @isnumeric);
addRequired(p, 'x', @isnumeric);
addRequired(p, 'y', @isnumeric);
addRequired(p, 'z', @isnumeric);
addRequired(p, 'qn', @isnumeric);
addRequired(p, 'Xi', @isnumeric);


%% Optional Inputs
addParameter(p, 'scalefactor', 1, @(x) all([isnumeric(x), numel(x) == 1, x>=0]) );
addParameter(p, 'Marker', '*');
addParameter(p, 'MarkerColor', [0,1,0]);
addParameter(p, 'MarkerSize', 10);

%% Parse the inputs
parse(p, axes_handle, e_in, IEN, ID, eltype, x, y, z, qn, Xi, varargin{:});

scalefactor = p.Results.scalefactor;
Marker      = p.Results.Marker;
MarkerColor = p.Results.MarkerColor;
MarkerSize  = p.Results.MarkerSize;

%%
%hnum = 0;
hlist = [];
std_element_defs;

%%

np = size(Xi,1);
for e = e_in
    
    [rx,ry,rz] = get_dof(IEN,ID,nen(eltype(e)),x,y,z,qn,scalefactor,e);
    
    Rx = nan(np,1);
    Ry = nan(np,1);
    Rz = nan(np,1);
    
    % compute the points
    for i = 1:np
        
        % compute the shape function
        if eltype(e) == 2
            % 3 node triangle
            NN = el2_ShapeFunctions(  Xi(i,1), Xi(i,2) );
        elseif eltype(e) == 3
            % 4 node quad
            NN = el3_ShapeFunctions(  Xi(i,1), Xi(i,2) );
        elseif eltype(e) == 4
            % 4 node tet
            NN = el4_ShapeFunctions(  Xi(i,1), Xi(i,2), Xi(i,3) );
        elseif eltype(e) == 5
            % 8 node hex
            NN = el5_ShapeFunctions(  Xi(i,1), Xi(i,2), Xi(i,3) );
        elseif eltype(e) == 6
            % 6 node wedge
            NN = el6_ShapeFunctions(  Xi(i,1), Xi(i,2), Xi(i,3) );
        elseif eltype(e) == 9
            % 6 node triangle
            NN = el9_ShapeFunctions(  Xi(i,1), Xi(i,2) );
        elseif eltype(e) == 10
            % 9 node quad
            NN = el10_ShapeFunctions( Xi(i,1), Xi(i,2) );
        elseif eltype(e) == 11
            % 10 node tet
            NN = el11_ShapeFunctions( Xi(i,1), Xi(i,2), Xi(i,3) );
        elseif eltype(e) == 12
            % 27 node hex
            NN = el12_ShapeFunctions( Xi(i,1), Xi(i,2), Xi(i,3) );
        elseif eltype(e) == 13
            % 18 node wedge
            NN = el13_ShapeFunctions( Xi(i,1), Xi(i,2), Xi(i,3) );
        else
            error('Error: element type eltype(%d) = %d is not implemented.\n',e,eltype);
        end
        
        Rx(i) = NN*rx;
        Ry(i) = NN*ry;
        Rz(i) = NN*rz;
        
    end
    
    % plot
    h1 = plot3(axes_handle, Rx, Ry, Rz, 'LineStyle', 'none', 'Marker', Marker, ...
        'MarkerEdgeColor', MarkerColor, 'MarkerFaceColor', MarkerColor, ...
        'MarkerSize', MarkerSize);
    
    hlist = [hlist, h1];
    
end

function [rx,ry,rz] = get_dof(IEN,ID,nen_e,x,y,z,qn,scalefactor,e)

A = IEN(1:nen_e,e);
xe = x(A);
ye = y(A);
ze = z(A);

idx = ID(1:3,A);
ue  = scalefactor*qn(idx(1,:));
ve  = scalefactor*qn(idx(2,:));
we  = scalefactor*qn(idx(3,:));

rx = xe+ue;
ry = ye+ve;
rz = ze+we;
