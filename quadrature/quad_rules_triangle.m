function [quad_rule] = quad_rules_triangle(opt)

%%
if strcmpi(opt.method, 'dun85b') 
    
    quad_rule = NaN;
    
    
elseif strcmpi(opt.method, 'Witherden') || strcmpi(opt.method, 'default')
    % Based on http://dx.doi.org/10.1016/j.camwa.2015.03.017    
    quad_rule = quad_WitherdenVincent2015_triangle(opt) ;

elseif strcmpi(opt.method, 'prod')
    
    quad_rule = quad_GL_triangle(opt.points);   
    
else
    
    error('Method <%s> not known', opt.method);
    
end
    
    