function hlist = plot_node_solution(axes_handle,A_in,color,scale,x, y, z, qn, ID)
figure(1);
%A_in=nnp= total number of nodes
%qn=qi= states of the nodes
%x: local position of the nodes?
% ID+[x y z]=global positino?
hlist = zeros(1,length(A_in));
for a = 1:length(A_in)
    A = A_in(a);
    
    P = ID(1,A);
    xo = scale*qn(P) + x(A);
    
    P = ID(2,A);
    yo = scale*qn(P) + y(A);
    
    P = ID(3,A);
    zo = scale*qn(P) + z(A);
    
    hlist(a) = ...
        plot3(axes_handle, xo, yo, zo, 'linestyle','none',...
        'Marker','*',...
        'Color',color,...
        'MarkerFaceColor',color,...
        'MarkerEdgeColor',color);
end