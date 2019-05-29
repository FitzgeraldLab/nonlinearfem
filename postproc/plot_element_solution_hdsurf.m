function hlist = plot_element_solution_hdsurf(axes_handle, e_in, scalefactor, RGBcolor,IEN, ID, eltype, x, y, z, qn, alpha0,flag_gridlines)

hnum = 0;
hlist = [];

if(nargin< 12)
    alpha0 = 1.0;
end
if( nargin < 13 )
    flag_gridlines = 1;
end

line_color = 'k';
line_width = 1.2;

for e = e_in
    if( eltype(e) == 10 )
        % 9-Node Quad.
        nen_e = 9;
        npoints = 10;
        xi0   = linspace(-1,1,npoints);
        
        a = 1:nen_e;
        A = IEN(a,e);
        
        xe = x(A);
        ye = y(A);
        ze = z(A);
        
        idx = ID(1,A);
        ue = scalefactor*qn(idx);
        idx = ID(2,A);
        ve = scalefactor*qn(idx);
        idx = ID(3,A);
        we = scalefactor*qn(idx);
        
        CData = zeros([npoints, npoints, 3]);
        
        % face
        x1p = zeros(npoints,npoints);
        y1p = zeros(npoints,npoints);
        z1p = zeros(npoints,npoints);
        for i1 = 1:npoints
            for i2 = 1:npoints
                NN = el10_ShapeFunctions(xi0(i1),xi0(i2));
                x1p(i1,i2) = NN*(xe+ue);
                y1p(i1,i2) = NN*(ye+ve);
                z1p(i1,i2) = NN*(ze+we);
                CData(i1,i2,:) = RGBcolor;
            end
        end
        if( flag_gridlines == 0 )
            h1 = surface(x1p, y1p, z1p, CData,'Parent',axes_handle,'EdgeColor','none');
        else
            h1 = surface(x1p, y1p, z1p, CData,'Parent',axes_handle);
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
        
    elseif( eltype(e) == 12 )
        % 27-Node hexahedral
        nen_e = 27;
        npoints = 10;
        xi0   = linspace(-1,1,npoints);
        
        a = 1:nen_e;
        A = IEN(a,e);
        xe = x(A);
        ye = y(A);
        ze = z(A);
            
        idx = ID(1,A);
        ue  = scalefactor*qn(idx);
        idx = ID(2,A);
        ve  = scalefactor*qn(idx);
        idx = ID(3,A);
        we  = scalefactor*qn(idx);
        
        CData = zeros([npoints, npoints, 3]);
        
        % face 1, eta = -1
        x1p = zeros(npoints,npoints);
        y1p = zeros(npoints,npoints);
        z1p = zeros(npoints,npoints);
        for i1 = 1:npoints
            for i2 = 1:npoints
                NN = el12_ShapeFunctions(xi0(i1),-1,xi0(i2));
                x1p(i1,i2) = NN*(xe+ue);
                y1p(i1,i2) = NN*(ye+ve);
                z1p(i1,i2) = NN*(ze+we);
                CData(i1,i2,:) = RGBcolor;
            end
        end
        h1 = surface(x1p, y1p, z1p, CData,'Parent',axes_handle);
        alpha(h1, alpha0);
        hnum = hnum + 1;
        hlist(e-e_in(1)+hnum) = h1;
        
        % face 2, zeta = 1
        x1p = zeros(npoints,npoints);
        y1p = zeros(npoints,npoints);
        z1p = zeros(npoints,npoints);
        for i1 = 1:npoints
            for i2 = 1:npoints
                NN = el12_ShapeFunctions(xi0(i1),xi0(i2), 1);
                x1p(i1,i2) = NN*(xe+ue);
                y1p(i1,i2) = NN*(ye+ve);
                z1p(i1,i2) = NN*(ze+we);
                CData(i1,i2,:) = RGBcolor;
            end
        end
        h2 = surface(x1p, y1p, z1p, CData,'Parent',axes_handle);
        alpha(h2, alpha0);
        hnum = hnum + 1;
        hlist(e-e_in(1)+hnum) = h2;
        
        % face 3, eta = 1
        x1p = zeros(npoints,npoints);
        y1p = zeros(npoints,npoints);
        z1p = zeros(npoints,npoints);
        for i1 = 1:npoints
            for i2 = 1:npoints
                NN = el12_ShapeFunctions(xi0(i1), 1,xi0(i2));
                x1p(i1,i2) = NN*(xe+ue);
                y1p(i1,i2) = NN*(ye+ve);
                z1p(i1,i2) = NN*(ze+we);
                CData(i1,i2,:) = RGBcolor;
            end
        end
        h3 = surface(x1p, y1p, z1p, CData,'Parent',axes_handle);
        alpha(h3, alpha0);
        hnum = hnum + 1;
        hlist(e-e_in(1)+hnum) = h3;
        
        % face 4, zeta = -1
        x1p = zeros(npoints,npoints);
        y1p = zeros(npoints,npoints);
        z1p = zeros(npoints,npoints);
        for i1 = 1:npoints
            for i2 = 1:npoints
                NN = el12_ShapeFunctions(xi0(i1),xi0(i2), -1);
                x1p(i1,i2) = NN*(xe+ue);
                y1p(i1,i2) = NN*(ye+ve);
                z1p(i1,i2) = NN*(ze+we);
                CData(i1,i2,:) = RGBcolor;
            end
        end
        h4 = surface(x1p, y1p, z1p, CData,'Parent',axes_handle);
        alpha(h4, alpha0);
        hnum = hnum + 1;
        hlist(e-e_in(1)+hnum) = h4;
        
        % face 5, xi = -1
        x1p = zeros(npoints,npoints);
        y1p = zeros(npoints,npoints);
        z1p = zeros(npoints,npoints);
        for i1 = 1:npoints
            for i2 = 1:npoints
                NN = el12_ShapeFunctions(-1,xi0(i1),xi0(i2));
                x1p(i1,i2) = NN*(xe+ue);
                y1p(i1,i2) = NN*(ye+ve);
                z1p(i1,i2) = NN*(ze+we);
                CData(i1,i2,:) = RGBcolor;
            end
        end
        h5 = surface(x1p, y1p, z1p, CData,'Parent',axes_handle);
        alpha(h5, alpha0);
        hnum = hnum + 1;
        hlist(e-e_in(1)+hnum) = h5;
        
        % face 6, xi = 1
        x1p = zeros(npoints,npoints);
        y1p = zeros(npoints,npoints);
        z1p = zeros(npoints,npoints);
        for i1 = 1:npoints
            for i2 = 1:npoints
                NN = el12_ShapeFunctions(1,xi0(i1),xi0(i2));
                x1p(i1,i2) = NN*(xe+ue);
                y1p(i1,i2) = NN*(ye+ve);
                z1p(i1,i2) = NN*(ze+we);
                CData(i1,i2,:) = RGBcolor;
            end
        end
        h6 = surface(x1p, y1p, z1p, CData,'Parent',axes_handle);
        alpha(h6, alpha0);
        hnum = hnum + 1;
        hlist(e-e_in(1)+hnum) = h6;
        hnum = hnum-1;
        
    else
        fprintf(2',['Error: unknown element type:',...
            ' eltype(%d) = %d\n'],e,eltype(e));
    end
    
end