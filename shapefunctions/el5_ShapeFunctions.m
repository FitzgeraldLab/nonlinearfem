function [NN,Nr,Ns,Nt] = el5_ShapeFunctions(r,s,t)

%% Compute shape functions for element5: linear 8 node hexahedron

NN = [(1+(-1).*r).*(1+(-1).*s).*(1+(-1).*t),(1+(-1).*r).*(1+s).*(1+(-1) ...
  .*t),(1+(-1).*r).*(1+s).*(1+t),(1+(-1).*r).*(1+(-1).*s).*(1+t),(1+ ...
  r).*(1+(-1).*s).*(1+(-1).*t),(1+r).*(1+s).*(1+(-1).*t),(1+r).*(1+ ...
  s).*(1+t),(1+r).*(1+(-1).*s).*(1+t)]/8;

Nr = [(-1).*(1+(-1).*s).*(1+(-1).*t),(-1).*(1+s).*(1+(-1).*t),(-1).*(1+ ...
  s).*(1+t),(-1).*(1+(-1).*s).*(1+t),(1+(-1).*s).*(1+(-1).*t),(1+s) ...
  .*(1+(-1).*t),(1+s).*(1+t),(1+(-1).*s).*(1+t)]/8;

Ns = [(-1).*(1+(-1).*r).*(1+(-1).*t),(1+(-1).*r).*(1+(-1).*t),(1+(-1).* ...
  r).*(1+t),(-1).*(1+(-1).*r).*(1+t),(-1).*(1+r).*(1+(-1).*t),(1+r) ...
  .*(1+(-1).*t),(1+r).*(1+t),(-1).*(1+r).*(1+t)]/8;

Nt = [(-1).*(1+(-1).*r).*(1+(-1).*s),(-1).*(1+(-1).*r).*(1+s),(1+(-1).* ...
  r).*(1+s),(1+(-1).*r).*(1+(-1).*s),(-1).*(1+r).*(1+(-1).*s),(-1).* ...
  (1+r).*(1+s),(1+r).*(1+s),(1+r).*(1+(-1).*s)]/8;