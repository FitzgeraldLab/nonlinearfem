function flag = simple_axes_check(ax)
%% check
% is ax an axis?
% -the isnumeric check is only a super lazy check for old systems.
% -the object check works on 2014b (and later?)


flag = 0;

if( isa(ax, 'matlab.graphics.axis.Axes') )
    
    flag = 1;
    
elseif( isnumeric(ax) )
    
    % make sure that if ax is a number that it is in the list of all axes
    h_AllAxes = findobj('type', 'axes');
    h_Legend = findobj(h_AllAxes,'tag','legend');
    h_Axes = setdiff(h_AllAxes,h_Legend); % All axes which are not legends

    if( any( ax == h_Axes ) )
        flag = 1;
    end
    
end

return

