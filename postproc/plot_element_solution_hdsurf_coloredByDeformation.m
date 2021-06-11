function hlist = plot_element_solution_hdsurf_coloredByDeformation(...
    axes_handle, IEN, ID, eltype, x, y, z, qn, varargin)

%% Parse input
p = inputParser;
addRequired( p, 'axes_handle', @simple_axes_check);
addRequired( p,         'IEN', @isnumeric);
addRequired( p,          'ID', @isnumeric);
addRequired( p,      'eltype', @isnumeric);
addRequired( p,           'x', @isnumeric);
addRequired( p,           'y', @isnumeric);
addRequired( p,           'z', @isnumeric);
addRequired( p,          'qn', @isnumeric);
addParameter(p,        'e_in', 1:size(IEN,2), @isnumeric);
addParameter(p, 'scalefactor',             1, @isnumeric);
addParameter(p,      'alpha0',           1.0, @isnumeric);
addParameter(p,   'points_per_elem',      10, @isnumeric);
addParameter(p,   'gridlines',             0, @isnumeric);
addParameter(p,       'field',  'displacement-norm2',   @ischar);
addParameter(p, 'field_range',           nan, @isnumeric);
addParameter(p,   'smoothing',             0, @isnumeric);

% Parse the inputs
parse(p, axes_handle, IEN, ID, eltype, x, y, z, qn, varargin{:});

e_in           = p.Results.e_in;
scalefactor    = p.Results.scalefactor;
alpha0         = p.Results.alpha0;
npoints        = p.Results.points_per_elem;
flag_gridlines = p.Results.gridlines;
flag_field     = p.Results.field;
flag_field_range=p.Results.field_range;
flag_smoothing = p.Results.smoothing;

        
%%

%hlist = zeros(size(e_in));
%hnum = 0;
hlist = [];

line_color = 'k';
line_width = 1.2;

for e = e_in
    if( eltype(e) == 10 )
        % 9-Node Quad.
        nen_e = 9;
        xi0   = linspace(-1,1,npoints);
        
        xe = zeros(nen_e,1);
        ye = zeros(nen_e,1);
        ze = zeros(nen_e,1);
        ue = zeros(nen_e,1);
        ve = zeros(nen_e,1);
        we = zeros(nen_e,1);
        
        for a = 1:nen_e
            
            idxA = IEN(a,e);
            xe(a) = x(idxA);
            ye(a) = y(idxA);
            ze(a) = z(idxA);
            
            idx = ID(1,idxA);
            ue(a) = scalefactor*qn(idx);
            idx = ID(2,idxA);
            ve(a) = scalefactor*qn(idx);
            idx = ID(3,idxA);
            we(a) = scalefactor*qn(idx);
            
        end
             
        % face
        x1p = zeros(npoints,npoints);
        y1p = zeros(npoints,npoints);
        z1p = zeros(npoints,npoints);
        CData = zeros(npoints, npoints);
        for i1 = 1:npoints
            for i2 = 1:npoints
                
                NN = el10_ShapeFunctions(xi0(i1),xi0(i2));
                x1p(i1,i2) = NN*(xe+ue);
                y1p(i1,i2) = NN*(ye+ve);
                z1p(i1,i2) = NN*(ze+we);
                
                if( strcmpi( flag_field, {'displacement-norm2'} ) )
                    
                    CData(i1,i2) = norm( [NN*ue, NN*ve, NN*we], 2);
                
                elseif( strcmpi( flag_field, {'displacement-x'} ) )
                    
                    CData(i1,i2) = NN*ue;
                    
                elseif( strcmpi( flag_field, {'displacement-y'} ) )
                    
                    CData(i1,i2) = NN*ve;
                    
                elseif( strcmpi( flag_field, {'displacement-z'} ) )
                    
                    CData(i1,i2) = NN*we;
                    
                else
                    error('Coloring field option <%s> is not yet defined', flag_field);
                end
                
            end
        end
        
        if( flag_gridlines == 0 )
            opt_EdgeColor = 'none';
        else
            opt_EdgeColor = [0 0 0];
        end
        
        if( flag_smoothing == 0 )
            opt_FaceColor = 'flat';
        else
            opt_FaceColor = 'interp';
        end
        
        h1 = surface(x1p, y1p, z1p, CData, 'Parent', axes_handle, ...
            'EdgeColor', opt_EdgeColor, ...
            'FaceColor', opt_FaceColor );
        
        if isnan(flag_field_range)
            caxis(axes_handle, 'auto');
        else
            caxis(axes_handle, flag_field_range);
        end
        
        alpha(h1, alpha0);
        %hnum = hnum + 1;
        %hlist(e-e_in(1)+hnum) = h1;
        %hnum = hnum - 1;
        hlist = [hlist, h1];
        
        if( flag_gridlines == 0 )
            % add edges
            % line 1
            x1p = zeros(1,npoints-1);
            y1p = zeros(1,npoints-1);
            z1p = zeros(1,npoints-1);
            for i1 = 1:npoints-1
                NN = el10_ShapeFunctions(xi0(i1),-1);
                x1p(i1) = NN*(xe+ue);
                y1p(i1) = NN*(ye+ve);
                z1p(i1) = NN*(ze+we);
            end
            % line 2
            x2p = zeros(1,npoints-1);
            y2p = zeros(1,npoints-1);
            z2p = zeros(1,npoints-1);
            for i1 = 1:npoints-1
                NN = el10_ShapeFunctions(1,xi0(i1));
                x2p(i1) = NN*(xe+ue);
                y2p(i1) = NN*(ye+ve);
                z2p(i1) = NN*(ze+we);
            end
            % line 3
            x3p = zeros(1,npoints-1);
            y3p = zeros(1,npoints-1);
            z3p = zeros(1,npoints-1);
            for i1 = 1:npoints-1
                NN = el10_ShapeFunctions(-xi0(i1),1);
                x3p(i1) = NN*(xe+ue);
                y3p(i1) = NN*(ye+ve);
                z3p(i1) = NN*(ze+we);
            end
            % line 4
            x4p = zeros(1,npoints);
            y4p = zeros(1,npoints);
            z4p = zeros(1,npoints);
            for i1 = 1:npoints
                NN = el10_ShapeFunctions(-1,-xi0(i1));
                x4p(i1) = NN*(xe+ue);
                y4p(i1) = NN*(ye+ve);
                z4p(i1) = NN*(ze+we);
            end
            
            h1 = line([x1p,x2p,x3p,x4p], [y1p,y2p,y3p,y4p], ...
                [z1p,z2p,z3p,z4p],...
                'Color',line_color,...
                'LineWidth',line_width,...
                'Parent',axes_handle);
            hlist = [hlist,h1];
        end
        
    else
        fprintf(2',['Error: unknown element type:',...
            ' eltype(%d) = %d\n'],e,eltype(e));
    end
    
end

