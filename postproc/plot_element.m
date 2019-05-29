function hlist = plot_element(axes_handle, e_in, color, IEN, eltype, x, y, z, alpha)

hlist = [];
if( nargin < 9 )
    alpha = 0.1;
end

for e = e_in
    
    if( eltype(e) == 1 )
        % 2-Node line
        if( nargin < 3)
            color = 'r';
        end
        
        xpts = x(IEN(1:2,e));
        ypts = y(IEN(1:2,e));
        plot(axes_handle,xpts,ypts,'color',color,'linewidth',2);
        
        for a = 1:length(xpts)
            h1 = plot(axes_handle,xpts(a),ypts(a),'linestyle','none','marker','*',...
                'color',color);
            hlist = [hlist,h1];
        end
        
    elseif( eltype(e) == 2 )
        %  2: 3-node triangle
        face(1,:) = [1 2 3];
        
        xpts = x(IEN(1:3,e));
        ypts = y(IEN(1:3,e));
        zpts = z(IEN(1:3,e));
        
        h1 = ...
        patch('Parent',axes_handle,'Vertices',[xpts, ypts, zpts],'Faces',face,...
            'FaceColor',color,'FaceAlpha',alpha);
        hlist = [hlist,h1];
        
    elseif( eltype(e) == 4 )
        %  4: 4-node tetrahedron
        face(1,:) = [1 2 3];
        face(2,:) = [1 2 4];
        face(3,:) = [1 3 4];
        face(4,:) = [2 3 4];
        
        xpts = x(IEN(1:4,e));
        ypts = y(IEN(1:4,e));
        zpts = z(IEN(1:4,e));
        
        h1 = ...
        patch('Parent',axes_handle,'Vertices',[xpts, ypts, zpts],'Faces',face,...
            'FaceColor',color,'FaceAlpha',alpha);
        hlist = [hlist,h1];
        
    elseif( eltype(e) == 5 || eltype(e) == 12 )
        %  8: 8-node hexahedral
        % 12: 27-node hexahedral
        face(1,:) = [1 4 8 5];
        face(2,:) = [5 6 7 8];
        face(3,:) = [6 2 3 7];
        face(4,:) = [2 1 4 3];
        face(5,:) = [4 8 7 3];
        face(6,:) = [1 5 6 2];
        
        xpts = x(IEN(1:8,e));
        ypts = y(IEN(1:8,e));
        zpts = z(IEN(1:8,e));
        
        h1 = ...
            patch('Parent',axes_handle,'Vertices',[xpts, ypts, zpts],'Faces',face,...
            'FaceColor',color,'FaceAlpha',alpha);
        hlist = [hlist,h1];
        
    elseif( eltype(e) == 9 )
        %  9: 6-node triangle
        face(1,:) = [1 4 2 5 3 6];
        
        xpts = x(IEN(1:6,e));
        ypts = y(IEN(1:6,e));
        zpts = z(IEN(1:6,e));
        
        h1 = ...
        patch('Parent',axes_handle,'Vertices',[xpts, ypts, zpts],'Faces',face,...
            'FaceColor',color,'FaceAlpha',alpha);
        hlist = [hlist,h1];
        
    elseif( eltype(e) == 10 )
        % 11: 9-node quad
        face(1,:) = [1 5 2 6 3 7 4 8];
        
        xpts = x(IEN(1:8,e));
        ypts = y(IEN(1:8,e));
        zpts = z(IEN(1:8,e));
        
        h1 = ...
        patch('Parent',axes_handle,'Vertices',[xpts, ypts, zpts],'Faces',face,...
            'FaceColor',color,'FaceAlpha',alpha);
        hlist = [hlist,h1];
        
    elseif( eltype(e) == 11 )
        % 11: 10-node tetrahedron
        face(1,:) = [1 5 2 6 3 7];
        face(2,:) = [1 5 2 10 4 8];
        face(3,:) = [1 7 3 9 4 8];
        face(4,:) = [2 6 3 9 4 10];
        
        xpts = x(IEN(1:10,e));
        ypts = y(IEN(1:10,e));
        zpts = z(IEN(1:10,e));
        
        h1 = ...
        patch('Parent',axes_handle,'Vertices',[xpts, ypts, zpts],'Faces',face,...
            'FaceColor',color,'FaceAlpha',alpha);
        hlist = [hlist,h1];
        
    else
        fprintf(2',...
            'Error: unknown element type: eltype(%d) = %d\n',...
            e,eltype(e));
    end
    
    clear face
end