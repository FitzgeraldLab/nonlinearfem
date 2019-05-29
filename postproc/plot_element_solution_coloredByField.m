function hlist = plot_element_solution_coloredByField(...
    axes_handle, e_in, scalefactor, ...
    IEN, ID, x, y, z, qn, alpha0,...
    color_field_e, ws_IEN, ws_eltype)

hlist = zeros(size(e_in));

for e = e_in
    
    if( ws_eltype(e) == 5 || ws_eltype(e) == 12 )
        % 8-Node or 27-Node hexahedron, only plotting the faces
        face(1,:) = [1 4 8 5];
        face(2,:) = [5 6 7 8];
        face(3,:) = [6 2 3 7];
        face(4,:) = [2 1 4 3];
        face(5,:) = [4 8 7 3];
        face(6,:) = [1 5 6 2];
        
        idx = ID(1:3,ws_IEN(1:8,e));
        
        xpts = x(ws_IEN(1:8,e)) + scalefactor*qn(idx(1,:));
        ypts = y(ws_IEN(1:8,e)) + scalefactor*qn(idx(2,:));
        zpts = z(ws_IEN(1:8,e)) + scalefactor*qn(idx(3,:));
        
        hlist(e-e_in(1)+1) = ...
            patch('Parent',axes_handle,'Vertices',[xpts, ypts, zpts],'Faces',face,...
            'FaceColor',color_field_e(e),'FaceAlpha',alpha0);
        
    elseif( ws_eltype(e) == 10 )
        % 11: 9-node quad
        face = [];
        face(1,:) = [1 5 2 6 3 7 4 8];
        
        idx = ID(1:3,ws_IEN(1:8,e));
        
        xpts = x(ws_IEN(1:8,e)) + scalefactor*qn(idx(1,:));
        ypts = y(ws_IEN(1:8,e)) + scalefactor*qn(idx(2,:));
        zpts = z(ws_IEN(1:8,e)) + scalefactor*qn(idx(3,:));
        
        % get scalar color info
        e_body = find_e_from_ws_e(e, ws_IEN, IEN, 9);
        
        hlist(e-e_in(1)+1) = ...
            patch('Parent',axes_handle,'Vertices',[xpts, ypts, zpts],'Faces',face,...
            'FaceVertexCData',color_field_e(e_body),'FaceAlpha',alpha0,'FaceColor','flat');
        
    else
        fprintf(2',['Error: unknown element type:',...
            ' eltype(%d) = %d\n'],e,ws_eltype(e));
    end
    
end


function e_out = find_e_from_ws_e(ws_e, ws_IEN, IEN, nen)
nel = size(IEN,2);
for e = 1:nel
    if( length( intersect(IEN(:,e), ws_IEN(:,ws_e)) )  == nen )
        e_out = e;
        return
    end
end



