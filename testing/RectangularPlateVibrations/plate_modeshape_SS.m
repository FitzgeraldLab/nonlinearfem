function X = plate_modeshape_SS(x, a, m)
% Leissa, eq 4.2
% m = 2, 3, 4, ...

X = sin( (m-1)*pi*x/a );
