function quad_rule = quad_GL_triangle(nt)

%% get single rule
quad_line = quad_GaussLegendre(nt, 1);

%% define a degenerate 4-node square
x = [-1,1,-1,-1]';
y = [-1,-1,1,1]';

%% init
quad_rule.method = 'GaussLegendre';
quad_rule.order  = '?';
quad_rule.domain = 'triangle: [-1,1]';
quad_rule.nt     = nt^2;
quad_rule.w      = nan(nt^2,1);
quad_rule.xi     = nan(nt^2,1);
quad_rule.eta    = nan(nt^2,1);

%% transform a square rule to the triangle
q = 0;
for i = 1:nt
    for j = 1:nt
        q = q+1;
        [NN,Nr,Ns] = el3_ShapeFunctions(quad_line.xi(i),quad_line.xi(j));
        
        quad_rule.xi(q)  = NN*x;
        quad_rule.eta(q) = NN*y;
        
        %% Compute mesh Jacobian
        J = [ Nr*x, Ns*x;
              Nr*y, Ns*y];
        det_J = det(J);
        
        quad_rule.w(q) = quad_line.w(i)*quad_line.w(j)*det_J;
        
    end
end