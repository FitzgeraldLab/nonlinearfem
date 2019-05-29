function [NN,Nr,Ns,Nt] = el4_ShapeFunctions(r,s,t)

%% Compute shape functions for element 4: linear 4 node tetrahedron
% $ r \in [-1,1] $
% $ s \in [-1,1] $
% $ t \in [-1,1] $
% $ r + s + t \leq 0 $

NN = [(1/2).*((-1)+(-1).*r+(-1).*s+(-1).*t),(1/2).*(1+r),(1/2).*(1+s),( ...
  1/2).*(1+t)];

Nr = [(-1/2),(1/2),0,0];

Ns = [(-1/2),0,(1/2),0];

Nt = [(-1/2),0,0,(1/2)];
