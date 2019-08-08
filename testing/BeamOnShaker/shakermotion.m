function [q,qd,qdd] = shakermotion(t,params)

std_element_defs;

%%
% params.A     : amplitude
% params.omega : frequency
% params.tau   : time constant of exponential decay
% params.dir   : which direction (1,2, or 3) that the shaker is moving in

tau = params.tau;
A   = params.A;
w   = params.omega;


% z(t) = A*sin(w*t)
% p(t) = 1 - e^(-t/tau)
% y = z p

%%
p   = 1 - exp(-t/tau);
pd  = -1/tau*(p-1); %% 1/tau*exp(-t/tau);
pdd = -1/tau*pd;    %% 1/tau*(-1/tau)*exp(-t/tau);

z   = A*sin(w*t);
zd  = A*w*cos(w*t);
zdd = -w^2*z;


%%
i = params.dir;

q    = zeros(ned,1);
q(i) = z*p;

qd    = zeros(size(q));
qd(i) = zd*p + z*pd;

qdd    = zeros(size(q));
qdd(i) = zdd*p + 2*zd*pd + z*pdd;
