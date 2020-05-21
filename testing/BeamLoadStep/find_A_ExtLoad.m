function A = find_A_ExtLoad(location, surface, Lx, Ly, Lz, x, y, z)

% determine if center or left edge:
if any( strcmpi(location, ["center", "mid"]) )
    xpos = Lx/2;
    
elseif any( strcmpi(location, ["L", "edge"]) )
    xpos = Lx;
else
    error("Location <%s> is an unknown option", location)
end

% determine which surface (in z)
if strcmpi( surface, "top" )
    zpos = Lz/2;

elseif any( strcmpi( surface, ["center", "mid"]) )
    zpos = 0;
    
elseif strcmpi( surface, "bottom")
    zpos = -Lz/2;
    
else
    error("Surface <%s> is an unknown option", surface)
end

%% search    
% Now each for the set of nodes that are in this region
tol = 1e-6;
A1 = find( abs(x - xpos) < tol );
A2 = abs(z(A1) - zpos) < tol;

A = A1(A2);
