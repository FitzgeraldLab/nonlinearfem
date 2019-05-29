function quad_rule = quad_rules_line(opt)

% rule generation procedure:
type = opt.method;

% number of points or order: opt.points

% dimensions of the line
ndim = 1;

%%
if strcmpi(type,'prod') || strcmpi(type,'default')
    % Generate the Gauss-Legendre tensor product weights and points 
    % on the interval [-1,1]
    quad_rule = quad_GaussLegendre(opt.points, ndim);

else
    error('Quadrature type <%s> is not known...', type)
    
end

