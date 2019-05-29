function [NN,Nr,Ns] = el2_ShapeFunctions(r,s)

%% Compute shape functions for 3 node triangle
% triangle part: $ r \in [-1,1] $, $ s \in [-1,1] $, $ r + s \leq 0 $

%%
NN = [(1/2).*((-1).*r+(-1).*s),(1/2).*(1+r),(1/2).*(1+s)];

Nr = [(-1/2),(1/2),0];

Ns = [(-1/2),0,(1/2)];
