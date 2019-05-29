function [E, nu, rho, matype] = set_mesh_materialparameters(nel, E_in, nu_in, rho_in, MATYPE_in, varargin)
%% Set the material Properties


%% Parse the inputs
p = inputParser;
isInput = @(x) any([isnumeric(x), isa(x, 'function_handle')]);

addRequired(p,       'nel', @isnumeric);
addRequired(p,      'E_in', isInput);
addRequired(p,     'nu_in', isInput);
addRequired(p,    'rho_in', isInput);
addRequired(p, 'MATYPE_in', isInput);

addParameter(p,   'x', NaN);
addParameter(p,   'y', NaN);
addParameter(p,   'z', NaN);
addParameter(p, 'IEN', NaN);

% Parse the inputs
parse(p, nel, E_in, nu_in, rho_in, MATYPE_in, varargin{:});
x   = p.Results.x;
y   = p.Results.y;
z   = p.Results.z;
IEN = p.Results.IEN;

%% Young's Modulus
if( isnumeric(E_in) )
    E = set_constant_params(nel, E_in, 'E');
elseif( isa(E_in, 'function_handle') )
    E = E_in(x,y,z,IEN);
else
    error('Option not yet implemented.');
    
end


%% Poisson's Ratio
if( isnumeric(nu_in) )
    nu = set_constant_params(nel, nu_in, 'nu');
elseif( isa(E_in, 'function_handle') )
    nu = nu_in(x,y,z,IEN);
else
    error('Option not yet implemented.');
end


%% Density
if( isnumeric(rho_in) )
    rho = set_constant_params(nel, rho_in, 'rho');
elseif( isa(rho_in, 'function_handle') )
    rho = rho_in(x,y,z,IEN);
else
    error('Option not yet implemented.');
end

%% Material Model
% set which material model to use
%   Krichoff = 1; Biot = 2; Hencky = 3;
if( isnumeric(MATYPE_in) )
    matype = set_constant_params(nel, MATYPE_in, 'matype');
else
    error('Option not yet implemented.');
end


%%
function X1 = set_constant_params(nel, X0, error_str)

if( any(isnan(X0)) )
    error('Why are there NaNs in the material property: %s?', error_str)
end

if( numel(X0) == 1 )
    X1(1:nel) = X0;
elseif( length(X0) == nel )
    X1(1:nel) = X0(1:nel);
else
    error('input size does not make sense in: %s', error_str);
end

