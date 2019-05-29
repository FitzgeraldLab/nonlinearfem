function hlist = plot_element_solution(axes_handle, e_in, scalefactor, color, ...
                                       IEN, ID, eltype, x, y, z, qn, alpha0, linecolor, linewidth)

hlist = zeros(size(e_in));
if(nargin < 12)
    alpha0 = 0.1;
end
if( nargin < 13 )
    linecolor = 'k';
end
if( nargin < 14 )
    linewidth = 2;
end
        
for e = e_in
    
    if( eltype(e) == 1 )
        % 2-Node linear bar
        
        a = 1:2;
        
        % x pts:
        i = 1;
        %p = a + nen_e*(i-1);
        %idx = LM(p,e);
        idx = ID(i,IEN(a,e));
        xpts = x(IEN(a,e)) + scalefactor*qn(idx)';
        
        % y pts:
        i = 2;
        %p = a + nen_e*(i-1);
        %idx = LM(p,e);
        idx = ID(i,IEN(a,e));
        ypts = y(IEN(a,e)) + scalefactor*qn(idx)';
        
        %figure(fig)
        plot(axes_handle,xpts,ypts,'color',color,'linewidth',2,'linestyle','--')
        
        for a = 1:length(xpts)
            plot(axes_handle,xpts(a),ypts(a),'linestyle','none','marker','*',...
                'color',color)
        end
        
    elseif( eltype(e) == 5 || eltype(e) == 12 )
        % 8-Node or 27-Node hexahedron, only plotting the faces
        face(1,:) = [1 4 8 5];
        face(2,:) = [5 6 7 8];
        face(3,:) = [6 2 3 7];
        face(4,:) = [2 1 4 3];
        face(5,:) = [4 8 7 3];
        face(6,:) = [1 5 6 2];
        
        A = IEN(1:8,e);
        idx = ID(1:3,A);
        
        xpts = x(A) + scalefactor*qn(idx(1,:));
        ypts = y(A) + scalefactor*qn(idx(2,:));
        zpts = z(A) + scalefactor*qn(idx(3,:));
        
        hlist(e-e_in(1)+1) = ...
            patch('Parent',axes_handle,'Vertices',[xpts, ypts, zpts],'Faces',face,...
            'FaceColor',color,'FaceAlpha',alpha0,'linewidth',linewidth);
        
    elseif( eltype(e) == 10 )
        % 11: 9-node quad
        
        face = [];
        face(1,:) = [1 5 2 6 3 7 4 8];
        
        A = IEN(1:8,e);
        idx = ID(1:3,A);
        
        xpts = x(A) + scalefactor*qn(idx(1,:));
        ypts = y(A) + scalefactor*qn(idx(2,:));
        zpts = z(A) + scalefactor*qn(idx(3,:));
        
        hlist(e-e_in(1)+1) = ...
            patch('Parent',axes_handle,'Vertices',[xpts, ypts, zpts],'Faces',face,...
            'FaceColor',color,'FaceAlpha',alpha0,'EdgeColor',linecolor,'linewidth',linewidth);
        
    else
        fprintf(2',['Error: unknown element type:',...
            ' eltype(%d) = %d\n'],e,eltype(e));
    end
    
end
