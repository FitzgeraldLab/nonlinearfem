function hlist = plot_element_solution_hdsurf2(axes_handle, e_in, IEN, ID, eltype, x, y, z, qn, varargin)


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


%% Optional Inputs
addParameter(p, 'scalefactor', 1, @(x) all([isnumeric(x), numel(x) == 1, x>=0]) );
addParameter(p, 'surf_color', [0,1,0]);
addParameter(p, 'surf_alpha', 0.8, @isnumeric);
addParameter(p, 'show_surfgridlines', false, @islogical);
addParameter(p, 'edge_color', 'k');
addParameter(p, 'edge_width', 1.2, @isnumeric);

addParameter(p, 'line_color', [250, 187, 50]/255 );
addParameter(p, 'line_width', 1.2, @isnumeric);


% HD surf options per element
addParameter(p, 'e8_pts_per_edge', 5, @isnumeric);
addParameter(p, 'e9_pts_per_edge', 5, @isnumeric);
addParameter(p, 'e10_pts_per_edge', 8, @isnumeric);

%% Parse the inputs
parse(p, axes_handle, e_in, IEN, ID, eltype, x, y, z, qn, varargin{:});

scalefactor = p.Results.scalefactor;
surf_color = p.Results.surf_color;
alpha0 = p.Results.surf_alpha;
flag_gridlines = p.Results.show_surfgridlines;
edge_color = p.Results.edge_color;
edge_width = p.Results.edge_width;

line_color = p.Results.line_color;
line_width = p.Results.line_width;

e8_pts_per_edge  = p.Results.e8_pts_per_edge;
e9_pts_per_edge  = p.Results.e9_pts_per_edge;
e10_pts_per_edge = p.Results.e10_pts_per_edge;

%%
%hnum = 0;
hlist = [];

%%
for e = e_in
    
    if eltype(e) == 8
        % 3-Node Line
        nen_e = 3;
        npoints = e8_pts_per_edge;
        
        [rx,ry,rz] = get_dof(IEN,ID,nen_e,x,y,z,qn,scalefactor,e);
        
        h1 = plot_e8_surface(axes_handle,rx,ry,rz,npoints, line_color,...
            line_width);
        hlist = [hlist,h1];
        
    elseif eltype(e) == 9
        % 6-Node triangle
        nen_e = 6;
        npoints = e9_pts_per_edge;
        
        [rx,ry,rz] = get_dof(IEN,ID,nen_e,x,y,z,qn,scalefactor,e);
        
        h1 = plot_e9_surface(axes_handle, rx, ry, rz, npoints, ...
            surf_color, alpha0, flag_gridlines, edge_color, edge_width);
        hlist = [hlist, h1];
        
        
    elseif eltype(e) == 10
        % 9-Node Quad.
        nen_e = 9;
        npoints = e10_pts_per_edge;
        
        [rx,ry,rz] = get_dof(IEN,ID,nen_e,x,y,z,qn,scalefactor,e);
        
        h1 = plot_e10_surface(axes_handle, rx, ry, rz, npoints, ...
            surf_color, alpha0, flag_gridlines, edge_color, edge_width);
        hlist = [hlist, h1];
        
        
    elseif eltype(e) == 11
        % 10-Node tetrahedron
        nen_e = 10;
        npoints = e10_pts_per_edge;
        
        [rx,ry,rz] = get_dof(IEN,ID,nen_e,x,y,z,qn,scalefactor,e);
        
        % setup faces
        face = nan(6,4);
        % bottom
        face(:,1) = [0,1,2,4,5,6]+1;
        % left
        face(:,2) = [0,1,3,4,9,7]+1;
        % right
        face(:,3) = [0,3,2,7,8,6]+1;
        % front
        face(:,4) = [3,1,2,9,5,8]+1;
        
        % plot
        for j = 1:4
            h1 = plot_e9_surface(axes_handle, ...
                rx(face(:,j)), ry(face(:,j)), rz(face(:,j)), npoints, ...
                surf_color, alpha0, flag_gridlines, edge_color, edge_width);
            hlist = [hlist, h1];
        end
        
    elseif eltype(e) == 12
        % 27-Node hexahedral
        nen_e = 27;
        npoints = e10_pts_per_edge;
        
        [rx,ry,rz] = get_dof(IEN,ID,nen_e,x,y,z,qn,scalefactor,e);
        
        face = nan(9,6);
        % bottom
        face(:,1) = [1,2,3,4,9,12,14,10,21];
        % front
        face(:,2) = [1,2,6,5,9,13,17,11,22];
        % left
        face(:,3) = [1,4,8,5,10,16,18,11,23];
        % right
        face(:,4) = [2,3,7,6,12,15,19,13,24];
        % back
        face(:,5) = [3,4,8,7,14,16,20,15,25];
        % top
        face(:,6) = [5,6,7,8,17,19,20,18,26];
        
        for j = 1:6
            h1 = plot_e10_surface(axes_handle,rx(face(:,j)), ...
                ry(face(:,j)), rz(face(:,j)), ...
                npoints, surf_color, alpha0, flag_gridlines, ...
                edge_color, edge_width);
            hlist = [hlist, h1];
        end
        
    elseif eltype(e) == 13
        % 18-Node wedge/prism
        nen_e = 18;
        
        [rx,ry,rz] = get_dof(IEN,ID,nen_e,x,y,z,qn,scalefactor,e);
        
        % plot the triangle parts:
        face = nan(6,2);
        % bottom
        face(:,1) = [0,2,1,7,9,6]+1;
        % top
        face(:,2) = [3,4,5,12,14,13]+1;
        for j = 1:2
            h1 = plot_e9_surface(axes_handle,rx(face(:,j)), ...
                ry(face(:,j)), rz(face(:,j)), ...
                e9_pts_per_edge, surf_color, alpha0, flag_gridlines, ...
                edge_color, edge_width);
            hlist = [hlist, h1];
        end
        
        
        % plot the quad parts:
        face = nan(9,3);
        face(:,1) = [0,1,4,3,6,10,12,8,15]+1;
        face(:,2) = [1,2,5,4,9,11,14,10,17]+1;
        face(:,3) = [2,0,3,5,7,8,13,11,16]+1;
        for j = 1:3
            h1 = plot_e10_surface(axes_handle,rx(face(:,j)), ...
                ry(face(:,j)), rz(face(:,j)), ...
                e10_pts_per_edge, surf_color, alpha0, flag_gridlines, ...
                edge_color, edge_width);
            hlist = [hlist, h1];
        end
        
    else
        fprintf(2',['Error: unknown element type:',...
            ' eltype(%d) = %d\n'],e,eltype(e));
    end
    
end

end

%%
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

end

%%
function h = plot_e8_surface(axes_handle,xe,ye,ze,npoints, line_color,...
    line_width)
% 3-Node Line

% face
xp = nan(npoints,1);
yp = nan(npoints,1);
zp = nan(npoints,1);

r = linspace(-1,1,npoints);

for i1 = 1:npoints
    rr = r(i1);
    NN = el8_ShapeFunctions(rr);
    xp(i1) = NN*(xe);
    yp(i1) = NN*(ye);
    zp(i1) = NN*(ze);
end

h = line(xp, yp, zp,...
    'Color',line_color,...
    'LineWidth',line_width,...
    'Parent',axes_handle);
end


%%
function h = plot_e9_surface(axes_handle,xe,ye,ze,npoints, surf_color,alpha0,flag_gridlines, edge_color, edge_width)
% 6-Node triangle

% face
ntotal = 1/2*npoints*(npoints+1);
x1p = nan(ntotal,1);
y1p = nan(ntotal,1);
z1p = nan(ntotal,1);
p = 0;
for i1 = 1:npoints
    for i2 = 1:i1
        p = p+1;
        s = (npoints - i1)/(npoints-1);
        r = 1/(npoints-1)*(i2-1);
        NN = el9_ShapeFunctions(2*r-1,2*s-1);
        x1p(p) = NN*(xe);
        y1p(p) = NN*(ye);
        z1p(p) = NN*(ze);
    end
end
tri = tessellate_triangle_IEN(npoints);

if( flag_gridlines == 0 )
    h = trisurf(tri, x1p, y1p, z1p, 'FaceColor', surf_color, 'Parent', axes_handle, 'EdgeColor','none');
else
    h = trisurf(tri, x1p, y1p, z1p, 'FaceColor', surf_color, 'Parent', axes_handle);
end


alpha(h, alpha0);

% draw the edge of the element
if( flag_gridlines == 0 )
    xi0 = linspace(-1,1,npoints);
    % add edges
    % line 1
    x1p = zeros(1,npoints-1);
    y1p = zeros(1,npoints-1);
    z1p = zeros(1,npoints-1);
    for i1 = 1:npoints-1
        NN = el9_ShapeFunctions(xi0(i1),-1);
        x1p(i1) = NN*(xe);
        y1p(i1) = NN*(ye);
        z1p(i1) = NN*(ze);
    end
    % line 2
    x2p = zeros(1,npoints-1);
    y2p = zeros(1,npoints-1);
    z2p = zeros(1,npoints-1);
    for i1 = 1:npoints-1
        NN = el9_ShapeFunctions(-xi0(i1),xi0(i1));
        x2p(i1) = NN*(xe);
        y2p(i1) = NN*(ye);
        z2p(i1) = NN*(ze);
    end
    % line 3
    x3p = zeros(1,npoints);
    y3p = zeros(1,npoints);
    z3p = zeros(1,npoints);
    for i1 = 1:npoints
        NN = el9_ShapeFunctions(-1,-xi0(i1));
        x3p(i1) = NN*(xe);
        y3p(i1) = NN*(ye);
        z3p(i1) = NN*(ze);
    end
    
    h1 = line([x1p,x2p,x3p], [y1p,y2p,y3p], ...
        [z1p,z2p,z3p],...
        'Color',edge_color,...
        'LineWidth',edge_width,...
        'Parent',axes_handle);
    h = [h,h1];
end

end


%%
function h = plot_e10_surface(axes_handle,xe,ye,ze,npoints, surf_color,alpha0,flag_gridlines, edge_color, edge_width)

xi0 = linspace(-1,1,npoints);
CData = zeros([npoints, npoints, 3]);

% face
x1p = zeros(npoints,npoints);
y1p = zeros(npoints,npoints);
z1p = zeros(npoints,npoints);
for i1 = 1:npoints
    for i2 = 1:npoints
        NN = el10_ShapeFunctions(xi0(i1),xi0(i2));
        x1p(i1,i2) = NN*(xe);
        y1p(i1,i2) = NN*(ye);
        z1p(i1,i2) = NN*(ze);
        CData(i1,i2,:) = surf_color;
    end
end
if( flag_gridlines == 0 )
    h = surface(x1p, y1p, z1p, CData,'Parent',axes_handle,'EdgeColor','none');
else
    h = surface(x1p, y1p, z1p, CData,'Parent',axes_handle);
end

alpha(h, alpha0);

% draw the edge of the element
if( flag_gridlines == 0 )
    % add edges
    % line 1
    x1p = zeros(1,npoints-1);
    y1p = zeros(1,npoints-1);
    z1p = zeros(1,npoints-1);
    for i1 = 1:npoints-1
        NN = el10_ShapeFunctions(xi0(i1),-1);
        x1p(i1) = NN*(xe);
        y1p(i1) = NN*(ye);
        z1p(i1) = NN*(ze);
    end
    % line 2
    x2p = zeros(1,npoints-1);
    y2p = zeros(1,npoints-1);
    z2p = zeros(1,npoints-1);
    for i1 = 1:npoints-1
        NN = el10_ShapeFunctions(1,xi0(i1));
        x2p(i1) = NN*(xe);
        y2p(i1) = NN*(ye);
        z2p(i1) = NN*(ze);
    end
    % line 3
    x3p = zeros(1,npoints-1);
    y3p = zeros(1,npoints-1);
    z3p = zeros(1,npoints-1);
    for i1 = 1:npoints-1
        NN = el10_ShapeFunctions(-xi0(i1),1);
        x3p(i1) = NN*(xe);
        y3p(i1) = NN*(ye);
        z3p(i1) = NN*(ze);
    end
    % line 4
    x4p = zeros(1,npoints);
    y4p = zeros(1,npoints);
    z4p = zeros(1,npoints);
    for i1 = 1:npoints
        NN = el10_ShapeFunctions(-1,-xi0(i1));
        x4p(i1) = NN*(xe);
        y4p(i1) = NN*(ye);
        z4p(i1) = NN*(ze);
    end
    
    h1 = line([x1p,x2p,x3p,x4p], [y1p,y2p,y3p,y4p], ...
        [z1p,z2p,z3p,z4p],...
        'Color',edge_color,...
        'LineWidth',edge_width,...
        'Parent',axes_handle);
    h = [h,h1];
end

end
