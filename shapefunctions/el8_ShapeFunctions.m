function [NN,Nr] = el8_ShapeFunctions(r)

%% Compute shape functions for 3 node line
% $ r \in [-1,1] $

NN = [r.^2/2 - r/2, r.^2/2 + r/2, 1 - r.^2];

Nr = [r - 1/2, r + 1/2, -2*r];
