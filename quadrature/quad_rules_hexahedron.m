function quad_rule = quad_rules_hexahedron(opt)

% rule generation procedure:
type = opt.method;

% number of points or order: opt.points

% dimensions of the hex = 3
ndim = 3;

%%
if strcmpi(type,'prod') || strcmpi(type,'default')
    % Generate the Gauss-Legendre tensor product weights and points 
    % on the interval [-1,1]
    quad_rule = quad_GaussLegendre(opt.points, ndim);
    
elseif strcmpi(type,'Witherden')
    % adapted from http://dx.doi.org/10.1016/j.camwa.2015.03.017
    % the function was auto-built in matlab from the appendix of that paper
    quad_rule = quad_WitherdenVincent2015_hex(opt);

else
    error('Quadrature type <%s> is not known...', type)
    
end

