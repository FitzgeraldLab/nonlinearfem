function [kfp, Qfp] = el10_compute_normalsurfaceload(xe,ye,ze,ue,ve,we, quad_nt, quad_xi, quad_eta, quad_w, pressure)
%#codegen
% Stiffness due to normal pressure

%%
nen_e = 9;
nee = 27;
ned = 3;

%% initialize the matricies
kfp = zeros(nee,nee);
Qfp = zeros(nee,1);

%% Define Integration loop
for i1 = 1:quad_nt
    xi = quad_xi(i1);
    eta = quad_eta(i1);
    
    %% Get Shape Functions, and local derivatives
    [NN, NNxi, NNeta] = el10_ShapeFunctions(xi,eta);
    N     = expand_shapeNN(NN    , nen_e, ned);
    Nxi   = expand_shapeNN(NNxi  , nen_e, ned);
    Neta  = expand_shapeNN(NNeta , nen_e, ned);
    
    %% compute R and it's derivatives
    dRdxi  = [NNxi*(xe+ue); NNxi*(ye+ve); NNxi*(ze+we)];
    dRdeta = [NNeta*(xe+ue); NNeta*(ye+ve); NNeta*(ze+we)];
    
    %% compute the normal vector
    %n = cross(dRdxi,dRdeta);
    %n = n/norm(n,2);
    
    %% compute inner terms of kfp
    A1 = crossProdMat(dRdxi);
    A2 = crossProdMat(-dRdeta);
        
    %% compute dV0
    dV0 = quad_w(i1);
    
    %% Build kfp
    kfp = kfp + (-pressure)*N'*(A1*Neta+A2*Nxi)*dV0;
    
    %% Build Qfp
    Qfp = Qfp + (-pressure)*N'*A1*dRdeta*dV0;
    
end

function A = crossProdMat(a)

A = [   0,-a(3), a(2);
     a(3),    0,-a(1);
    -a(2), a(1),   0];