function [ke, Qs] = el12_ke_biot(X, qe,E, nu, quad_nt, quad_xi, quad_eta, quad_zeta,quad_w) %#codegen
% Biot-material Element
% {^(i)q}: previous state of q

%%
ned = 3;
nen_e = 27;
nee = 81;

%% initialize the matricies
kb = zeros(nee,nee);
ks = zeros(nee,nee);
Qs = zeros(nee,1);

%% Define Integration loop
for i1 = 1:quad_nt
    xi = quad_xi(i1);
    eta = quad_eta(i1);
    zeta = quad_zeta(i1);
    
    %% Get Shape Functions, and local derivatives
    [~,NNxi,NNeta,NNzeta] = el12_ShapeFunctions(xi,eta,zeta);
    
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
    F = [ Nx*qe, Ny*qe, Nz*qe ] + eye(3);
    [Psi, Sigma, Lambda] = svd(F);
    U = Lambda*Sigma*Lambda';
    R = Psi*Lambda';
    Tr_U = Sigma(1,1)+Sigma(2,2)+Sigma(3,3);
    Y = Tr_U*eye(3)-U;
    detY = det(Y);
    L = U-eye(3);
    lambda = E*nu/(1+nu)/(1-2*nu);
    mu = E/2/(1+nu);
    Tr_L = L(1,1)+L(2,2)+L(3,3);
    G = lambda*Tr_L*eye(3) + 2*mu*L;
    S = U\G;
    DS = zeros(6,nee);
    for k = 1:nee
        dF = [Nx(:,k),Ny(:,k),Nz(:,k)];
        theta = R'*dF-1/detY*Y*(R'*dF-dF'*R)*Y*U;
        Tr_theta = theta(1,1)+theta(2,2)+theta(3,3);
        dS = (lambda*Tr_theta*eye(3)+2*mu*theta-S*theta)/U;
        DS(:,k) = [dS(1,1);
            dS(2,2);
            dS(3,3);
            dS(2,3);
            dS(1,3);
            dS(1,2)];
    end
    S = [S(1,1);
        S(2,2);
        S(3,3);
        S(2,3);
        S(1,3);
        S(1,2)];
    
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
%fprintf(1,'\t\t\t%.3e\t%.3e\n',norm(ks,1),norm(kb,1));
%% Output element stiffness:
ke = kb+ks;