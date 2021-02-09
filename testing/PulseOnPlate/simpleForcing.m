function f = simpleForcing(X, Y, Z, t, params)
% this is an example forcing function that acts only on the Z-direction

f = zeros(3,1);

A = params.A;
omega = params.omega;
idx = params.dir; % = 3;
f(idx) = A*sin(omega*t);
