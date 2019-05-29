function [me] = el11_me(X, rho, quad_nt, quad_xi, quad_eta, quad_zeta, quad_w) %#codegen
% Mass matrix Element
% {^(i)q}: previous state of q

%%
ned = 3;
nen_e = 10;
nee = 30;

%% initialize the matricies
me = zeros(ned*nen_e,ned*nen_e);

%% Define Integration loop
for i1 = 1:quad_nt
    xi = quad_xi(i1);
    eta = quad_eta(i1);
    zeta = quad_zeta(i1);
    
    %% Get Shape Functions, and local derivatives
    [NN,NNxi,NNeta,NNzeta] = el11_ShapeFunctions(xi,eta,zeta);
    
    %% Build [N]
    N     = expand_shapeNN(NN    , nen_e, ned);
    Nxi   = expand_shapeNN(NNxi  , nen_e, ned);
    Neta  = expand_shapeNN(NNeta , nen_e, ned);
    Nzeta = expand_shapeNN(NNzeta, nen_e, ned);
    
    %% Compute Jacobian
    J = [Nxi*X, Neta*X, Nzeta*X];
    detJ = det(J);
    
    %% compute dV0
    dV0 = detJ*quad_w(i1);
    
    %% Build me
    me = me + rho*(N'*N)*dV0;
    
end
