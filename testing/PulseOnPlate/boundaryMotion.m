function [q,qd,qdd] = boundaryMotion(t,params)

std_element_defs;

q    = zeros(ned,1);
qd   = zeros(ned,1);
qdd  = zeros(ned,1);
