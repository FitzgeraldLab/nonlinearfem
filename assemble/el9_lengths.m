function lengths = el9_lengths( xe, ye, ze, ue, ve, we, ...
    quad_line_nt, quad_line_xi, quad_line_w)%#codegen


% init the lengths
lengths = zeros(3,1);

%
rx = xe+ue;
ry = ye+ve;
rz = ze+we;

% Compute bottom edge length at (xi,eta) = (s,-1)
for i1 = 1:quad_line_nt
    xi = quad_line_xi(i1);
    eta = -1;
    
    [~,NNxi,~] = el9_ShapeFunctions(xi,eta);
    
    % Compute the absolute position dr/dxi = Nr*(X + q)
    dr = [NNxi*rx, NNxi*ry, NNxi*rz];
    lengths(1) = lengths(1) + norm(dr,2)*quad_line_w(i1);
    
end

% Compute left edge at (xi,eta) = (-1,s)
for i1 = 1:quad_line_nt
    xi = -1;
    eta = quad_line_xi(i1);
    
    [~,~,NNeta] = el9_ShapeFunctions(xi,eta);
    
    % Compute the absolute position dr/deta = Ns*(X + q)
    ds = [NNeta*rx, NNeta*ry, NNeta*rz];
    
    lengths(2) = lengths(2) + norm(ds,2)*quad_line_w(i1);
    
end

% Compute right edge xi+eta = 0
for i1 = 1:quad_line_nt
    s = quad_line_xi(i1);
    xi = s;
    eta = -s;
    
    [~,NNxi,NNeta] = el9_ShapeFunctions(xi,eta);
    
    % Compute the absolute position dr/ds = Ns*r;
    % Ns = Nxi*dxi/ds + Neta*deta/ds
    Ns = NNxi*(1) + NNeta*(-1);
    ds = [Ns*rx, Ns*ry, Ns*rz];
    
    lengths(3) = lengths(3) + norm(ds,2)*quad_line_w(i1);
    
end

