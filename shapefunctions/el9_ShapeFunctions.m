function [NN,Nr,Ns] = el9_ShapeFunctions(r,s)

%% Compute shape functions for 6 node triangle
% triangle part: $ r \in [-1,1] $, $ s \in [-1,1] $, $ r + s \leq 1 $

NN = [(1/2).*(r+s).*(1+r+s),(1/2).*r.*(1+r),(1/2).*s.*(1+s),(-1).*(1+r) ...
  .*(r+s),(1+r).*(1+s),(-1).*(1+s).*(r+s)];

Nr = [(1/2)+r+s,(1/2)+r,0,(-1)+(-2).*r+(-1).*s,1+s,(-1)+(-1).*s];

Ns = [(1/2)+r+s,0,(1/2)+s,(-1)+(-1).*r,1+r,(-1)+(-1).*r+(-2).*s];
