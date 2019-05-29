function inertia = el12_inertia(xe,ye,ze, ue,ve,we, MatDensity, ref_pt, quad_nt, quad_xi, quad_eta, quad_zeta, quad_w)
%#codegen

X = [xe; ye; ze];
inertia = zeros(3,3);
nen_e = 27;
ned = 3;

%% Define Integration loop
for i1 = 1:quad_nt
    xi = quad_xi(i1);
    eta = quad_eta(i1);
    zeta = quad_zeta(i1);
    
    %% Get Shape Functions, and local derivatives
    [NN,NNxi,NNeta,NNzeta] = el12_ShapeFunctions(xi,eta,zeta);
    
    %% Build [N]
    %N     = expand_shapeNN(NN    , nen_e, ned);
    Nxi   = expand_shapeNN(NNxi  , nen_e, ned);
    Neta  = expand_shapeNN(NNeta , nen_e, ned);
    Nzeta = expand_shapeNN(NNzeta, nen_e, ned);
    
    %% Compute Jacobian
    J = [Nxi*X, Neta*X, Nzeta*X];
    detJ = det(J);
    
    %% compute dV0
    dV0 = detJ*quad_w(i1);
    
    %% Build the positions
    
    % Compute absolute potition
    r = [ NN*(xe+ue); NN*(ye+ve); NN*(ze+we)];
    
    % compute the vector from the ref_point
    y = r - ref_pt;
    
    %% compute the integrand
    integrand = (y'*y)*eye(3) - y*y';
    
    %% compute the moment of inertia
    inertia = inertia + MatDensity*integrand*dV0;
    
end

