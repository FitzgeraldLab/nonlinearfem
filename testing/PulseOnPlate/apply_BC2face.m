function [fix, A] = apply_BC2face(msh, x, y, z, fix_in, face, BC)

fix = fix_in;
[~,~,temp_IEN] = parse_msh(msh, face);
A = unique(temp_IEN(:));

if( isempty(A) )
    error('Problem with finding the set of nodes')
end

if( any( strcmpi( BC, {'fixed', 'clamp', 'c'}) ) )
    
    % completely Fix these nodes
    fix(1:3, A) = 1;
    
elseif( any( strcmpi( BC, {'S', 'ss', 'pin', 'hinge', 'simplysupported'}) ) )
    
    % find nodes near the center of the plate
    A = A( abs( z(A) - 0) <= 1e-10 );
    
    if( length(A) < 2 )
        error('Problem with the mesh');
    end
    
    % completely Fix these nodes
    fix(1:3, A) = 1;
    
    
elseif( any( strcmpi( BC, {'F', 'free'}) ) )
    
    fix(1:3, A) = 0;
    
else
    
    error('BC %s is not define for face %s', BC, face);
    
end

return
