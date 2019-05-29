function quad_rule = quad_GL_tet(nt)

%% get single rule
quad_line = quad_GaussLegendre(nt, 1);

%% define a degenerate 8-node hex
x = 2*[0, 1, 0, 0, 0, 0, 0, 0]' - 1;
y = 2*[0, 0, 1, 1, 0, 0, 0, 0]' - 1;
z = 2*[0, 0, 0, 0, 1, 1, 1, 1]' - 1;

%% init
quad_rule.method = 'GaussLegendre';
quad_rule.order  = '?';
quad_rule.domain = 'tetrahedron: [-1,1]';
quad_rule.nt     = nt^3;
quad_rule.w      = nan(nt^3,1);
quad_rule.xi     = nan(nt^3,1);
quad_rule.eta    = nan(nt^3,1);
quad_rule.zeta   = nan(nt^3,1);

%% transform a square rule to the triangle
q = 0;
for i = 1:nt
    xi = quad_line.xi(i);
    
    for j = 1:nt
        eta = quad_line.xi(j);
        
        for k = 1:nt
            q = q+1;
            zeta = quad_line.xi(k);
            
            [NN,Nr,Ns,Nt] = el5_ShapeFunctions(xi,eta,zeta);
            
            quad_rule.xi(q)   = NN*x;
            quad_rule.eta(q)  = NN*y;
            quad_rule.zeta(q) = NN*z;
            
            %% Compute mesh Jacobian
            J = [ Nr*x, Ns*x, Nt*x;
                  Nr*y, Ns*y, Nt*y;
                  Nr*z, Ns*z, Nt*z];
            det_J = det(J);
            
            quad_rule.w(q) = quad_line.w(i)*quad_line.w(j)*quad_line.w(k)*det_J;
            
        end
    end
end