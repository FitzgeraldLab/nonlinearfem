function [eVolume] = el12_compute_Volume(...
    Xe, qe, ...
    quad_nt, quad_xi, quad_eta, quad_zeta, quad_w)
%#codegen

ned = 3;
nen_e = 27;
nee   = nen_e*ned;

eVolume=0;% calculate the volume of the element
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
    
    %% Compute mesh Jacobian
    meshJ = [Nxi*Xe, Neta*Xe, Nzeta*Xe];
    det_meshJ = det(meshJ);
    
    %% Derivative matrix DN
    DN = [NNxi', NNeta', NNzeta']/meshJ;
    
    %% Build Nx, Ny, Nz
    Nx = expand_shapeNN(DN(:,1), nen_e, ned);
    Ny = expand_shapeNN(DN(:,2), nen_e, ned);
    Nz = expand_shapeNN(DN(:,3), nen_e, ned);
    
    %% Compute the stress [S] and Strain [E]
    F = [ Nx*qe, Ny*qe, Nz*qe ] + eye(3);
    det_F = det(F);   
        
    %% compute dV0
    dV0 = det_meshJ*quad_w(i1);
    
    %% compute dV
    dV = det_F*dV0;
    
    %% Integrate
    eVolume = eVolume + dV;
end

