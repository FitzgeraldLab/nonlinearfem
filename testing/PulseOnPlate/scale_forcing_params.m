function out = scale_forcing_params(forcingparams, E, Lx, Ly, Lz)
% based on simple linear beam approximation for max deflection at the tip

% delta_max = w*L^4/(8EI)
% w = A*Ly
% solve for A


delta_max = forcingparams.rel_amp*Lz;
I = 1/12*Ly*Lz^3;

out = forcingparams;
out.A = delta_max*8*E*I/Lx^4/(Ly);

