function [quad_rule] = quad_rules_tetrahedron(opt)

%%
if strcmpi(opt.method, 'prod') || strcmpi(opt.method, 'default')
    % Generate the Gauss-Legendre tensor product weights and points 
    % on the interval [-1,1]
    quad_rule = quad_GL_tet(opt.points);
    
elseif strcmpi(opt.method, 'Witherden')

    % adapted from http://dx.doi.org/10.1016/j.camwa.2015.03.017
    % the function was auto-built in matlab from the appendix of that paper
    quad_rule = quad_WitherdenVincent2015_tet(opt);
    
else
    
    error('Method <%s> not known', opt.method);
    
end
    
    