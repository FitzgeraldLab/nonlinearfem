function plot_node_solution_ByElement(axes_handle,e_in,color,scale,x, y, z, IEN, qn, eltype, nen, nnp, ID)

mask = zeros(1,nnp);

for e = e_in
    
    nen_e = nen(eltype(e));
    
    for a = 1:nen_e
        
        A = IEN(a,e);
        
        if( mask(A) == 0 )
            
            P = ID(1,A);
            xo = scale*qn(P) + x(A);
            
            P = ID(2,A);
            yo = scale*qn(P) + y(A);
            
            P = ID(3,A);
            zo = scale*qn(P) + z(A);
            
            plot3(axes_handle, xo, yo, zo, 'linestyle','none',...
                'Marker','*',...
                'Color',color,...
                'MarkerFaceColor',color,...
                'MarkerEdgeColor',color);
            
            mask(A) = 1;
        end
    end
    
end