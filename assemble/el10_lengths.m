function lengths = el10_lengths( xe, ye, ze, ue, ve, we, ...
    quad_line_nt, quad_line_xi, quad_line_w)%#codegen


% init the lengths
lengths = zeros(2,1);

%
rx = xe+ue;
ry = ye+ve;
rz = ze+we;

% Compute length at (xi,eta) = (s,0)
for i1 = 1:quad_line_nt
    xi = quad_line_xi(i1);
    eta = 0.;
    
    [~,NNxi,~] = el10_ShapeFunctions(xi,eta);
    
    % Compute the absolute position dr/dxi = Nr*(X + q)
    dr = [NNxi*rx, NNxi*ry, NNxi*rz];
    lengths(1) = lengths(1) + norm(dr,2)*quad_line_w(i1);
    
end

% Compute length at (xi,eta) = (0,s)
for i1 = 1:quad_line_nt
    xi = 0.;
    eta = quad_line_xi(i1);
    
    [~,~,NNeta] = el10_ShapeFunctions(xi,eta);
    
    % Compute the absolute position dr/deta = Ns*(X + q)
    ds = [NNeta*rx, NNeta*ry, NNeta*rz];
    
    lengths(2) = lengths(2) + norm(ds,2)*quad_line_w(i1);
    
end

%% Notes from Shane
% arc length along s=0
% ds = \sqrt{dx^2+dy^2+dz^2 }
% x = N_i x_i
% dx = d(N_i)/dr x_i dr
% similarly,
% dy = d(N_i)/dr y_i dr
% dz = d(N_i)/dr z_i dr

