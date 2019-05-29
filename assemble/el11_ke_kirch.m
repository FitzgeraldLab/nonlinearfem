function [ke, Qs] = el11_ke_kirch(X, qe,E, nu, quad_nt, quad_xi, quad_eta, quad_zeta,quad_w) %#codegen
% Kirchoff-material Element
% {^(i)q}: previous state of q

%%
%global nen ned x y z IEN ID eltype qi
%global quad E nu

ned = 3;
nen_e = 10;
nee = ned*nen_e;

%% initialize the matricies
kb = zeros(nee,nee);
ks = zeros(nee,nee);
Qs = zeros(nee,1);

%I3 = eye(3);

G = E/(2*(1+nu));
lambda = E*nu/(1+nu)/(1-2*nu);
C = [2*G+lambda,  lambda   ,  lambda   , 0, 0, 0;
    lambda   , 2*G+lambda,  lambda   , 0, 0, 0;
    lambda   ,  lambda   , 2*G+lambda, 0, 0, 0;
    0      ,    0      ,    0      , G, 0, 0;
    0      ,    0      ,    0      , 0, G, 0;
    0      ,    0      ,    0      , 0, 0, G];

%% Define Integration loop
for i1 = 1:quad_nt
    xi = quad_xi(i1);
    eta = quad_eta(i1);
    zeta = quad_zeta(i1);
    
    %% Get Shape Functions, and local derivatives
    [~,NNxi,NNeta,NNzeta] = el11_ShapeFunctions(xi,eta,zeta);
    
    %% Build [N]
    %N     = expand_shapeNN(NN    , nen_e, ned);
    Nxi   = expand_shapeNN(NNxi  , nen_e, ned);
    Neta  = expand_shapeNN(NNeta , nen_e, ned);
    Nzeta = expand_shapeNN(NNzeta, nen_e, ned);
    
    %% Compute Jacobian
    J = [Nxi*X, Neta*X, Nzeta*X];
    detJ = det(J);
    
    %% Derivative matrix DN
    DN = [NNxi', NNeta', NNzeta']/J;
    
    %% Build Nx, Ny, Nz
    Nx = expand_shapeNN(DN(:,1), nen_e, ned);
    Ny = expand_shapeNN(DN(:,2), nen_e, ned);
    Nz = expand_shapeNN(DN(:,3), nen_e, ned);
    
    %% Build DXX, DYY, DZZ, DYZ, DXZ, DXY
    DXX = Nx'*Nx;
    DYY = Ny'*Ny;
    DZZ = Nz'*Nz;
    DYZ = Ny'*Nz;
    DXZ = Nx'*Nz;
    DXY = Nx'*Ny;
    
    %% Build B
    B = [ (X + qe)'*DXX;
        (X + qe)'*DYY;
        (X + qe)'*DZZ;
        (X + qe)'*(DYZ' + DYZ);
        (X + qe)'*(DXZ' + DXZ);
        (X + qe)'*(DXY' + DXY)];
    
    %% Get the stress: {S} and [DS]
    DS = C*B;
    Estrain = [ 1/2*qe'*DXX*qe + X'*DXX*qe;
        1/2*qe'*DYY*qe + X'*DYY*qe;
        1/2*qe'*DZZ*qe + X'*DZZ*qe;
        qe'*DYZ*qe + X'*(DYZ'+DYZ)*qe;
        qe'*DXZ*qe + X'*(DXZ'+DXZ)*qe;
        qe'*DXY*qe + X'*(DXY'+DXY)*qe];
    S = C*Estrain;
    
    %% compute dV0
    dV0 = detJ*quad_w(i1);
    
    %% Build kb
    kb = kb + B'*DS*dV0;
    
    %% Build ks
    ks = ks + (DXX*S(1) + DYY*S(2) + DZZ*S(3) ...
        + (DYZ'+DYZ)*S(4) + (DXZ'+DXZ)*S(5) + (DXY'+DXY)*S(6))*dV0;
    
    %% Build Qs
    Qs = Qs + B'*S*dV0;
    
end

%% Output element stiffness:
ke = kb+ks;