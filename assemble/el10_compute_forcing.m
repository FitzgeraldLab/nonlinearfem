function [Qfp] = el10_compute_forcing(xe,ye,ze,ue,ve,we, quad_nt, quad_xi, quad_eta, quad_w, forcing, time)
%#codegen
% Forcing due to the surface traction with globally defined forcing(X,Y,Z,t)
% to ensure the integration is accurate, the forcing should be spread
% across the body/element and smooth (or at least polymonial-like).  No
% singularities, no impulses.

%%
nen_e = 9;
nee = 27;
ned = 3;

%% initialize the matricies
Qfp = zeros(nee,1);

%% Define Integration loop
for i1 = 1:quad_nt
    xi = quad_xi(i1);
    eta = quad_eta(i1);
    
    %% Get Shape Functions, and local derivatives
    [NN, NNxi, NNeta] = el10_ShapeFunctions(xi,eta);
    N     = expand_shapeNN(NN    , nen_e, ned);
%     Nxi   = expand_shapeNN(NNxi  , nen_e, ned);
%     Neta  = expand_shapeNN(NNeta , nen_e, ned);
    
    %% compute R and it's derivatives
    dRdxi  = [NNxi*(xe+ue); NNxi*(ye+ve); NNxi*(ze+we)];
    dRdeta = [NNeta*(xe+ue); NNeta*(ye+ve); NNeta*(ze+we)];
    
    %% compute the normal vector
    %n = cross(dRdxi,dRdeta);
    %n = n/norm(n,2);
       
    %% compute dV0
    dA = quad_w(i1)*norm( cross(dRdxi,dRdeta), 2);
    
    %% forcing  
    fe = forcing(NN*xe, NN*ye, NN*ze, time);
       
    %% Build Qfp
    Qfp = Qfp + N'*fe*dA;
    
end
