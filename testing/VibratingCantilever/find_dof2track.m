function [idx,A] = find_dof2track( x, y, z, ID, Fext_dir, A_Fext)

% locate the node closest to (x,y,z) = (L,0,0) that is being forced
zpos = 0;
ypos = 0;

z1 = z(A_Fext);
y1 = y(A_Fext);

%% search    
% Now each for the set of nodes that are in this region
tol = 1e-6;
A1 = find( abs(z1 - zpos) < tol );
A2 = abs(y1(A1) - ypos) < tol;

iA = A1(A2);


%% locate dof to track:
A = A_Fext(iA);
idx = ID(Fext_dir, A);





