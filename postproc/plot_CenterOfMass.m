function hlist = plot_CenterOfMass(axes_handle,x,y,z,color,scale,markerSize)

if( nargin < 5)
    color = 'k';
end
if( nargin < 6 )
    scale = 1;
end
if( nargin < 7 )
    markerSize = 10;
end

xo = scale*x;
yo = scale*y;
zo = scale*z;

hlist = ...
    plot3(axes_handle, xo, yo, zo, 'linestyle','none',...
    'Marker','o',...
    'Color',color,...
    'MarkerFaceColor',color,...
    'MarkerEdgeColor',color,...
    'MarkerSize',markerSize);
