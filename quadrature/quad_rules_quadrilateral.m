function [quad_rule] = quad_rules_quadrilateral(opt)

% rule generation procedure:
%type = opt.method;

% number of points or order: opt.points

% dimensions of the hex = 3
ndim = 2;

%%
if strcmpi(opt.method, 'prod') || strcmpi(opt.method, 'default')
    % Generate the Gauss-Legendre tensor product weights and points 
    % on the interval [-1,1]
    quad_rule = quad_GaussLegendre(opt.points, ndim);
    
elseif strcmpi(opt.method, 'Witherden')
    %
    quad_rule = NaN;
    
else
    
    error('Method <%s> not known', opt.method);
    
end
    
    