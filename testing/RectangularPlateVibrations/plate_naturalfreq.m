function lambda = plate_naturalfreq( a, m, b, n, BC_x, BC_y, nu)
%% \lamba_{mn} = \omega_{mn} a^2 \sqrt{\rho/D}
% Leissa, eq 4.16 and parts of Table 4.1

[Gx, Hx, Jx] = coeffs(BC_x, m);
[Gy, Hy, Jy] = coeffs(BC_y, n);

lambda2 = pi^4*( Gx^4 + Gy^4*(a/b)^4 + 2*(a/b)^2*(nu*Hx*Hy + (1-nu)*Jx*Jy) );
lambda = sqrt(lambda2);

function [G, H, J] = coeffs(BC, m)
    % from Table 4.1

if( strcmpi(BC, 'SS') )
    % Simply supported at x = 0 and x = a
    if( m < 2 )
        error('m is too small, m >= 2'); 
    end
    
    G = m-1;
    H = (m-1)^2;
    J = (m-1)^2;
    
elseif( strcmpi(BC, 'CC') )
    
    if( m == 2 )
        
        G = 1.506;
        H = 1.248;
        J = H;
        
    elseif( m >= 3 )
        
        G = m-1/2;
        H = (m-1/2)^2 * (1 - 2/(m-1/2)/pi );
        J = H;
        
    else
        error('m is bad, m >= 2');
    end
    
    
elseif( strcmpi(BC, 'FF') )
    
    if( m == 0 )
        
        G = 0;
        H = 0;
        J = 0;
        
    elseif( m == 1 )
        
        G = 0;
        H = 0;
        J = 12/pi^2;
        
    elseif( m == 2 )
        
        G = 1.506;
        H = 1.248;
        J = 5.017;
        
    elseif( m >= 3 )
        
        G = m-1/2;
        H = (m-1/2)^2*(1 - 2/(m-1/2)/pi);
        J = (m-1/2)^2*(1 + 6/(m-1/2)/pi);
        
    else
        error('m is bad');
    end
    
else
    error('BC type is not implemeted');
end


