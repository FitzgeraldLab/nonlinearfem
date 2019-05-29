function [body_COM, body_mass] = assemble_COM(nel, IEN, ID, eltype, rho, quad_rules, x, y, z, qn)

%%
moment_b = [0;0;0];
mass_b = 0;

%%
nen = [2, 3, 4, 4, 8, 6, 5, 3, 6, 9, 10, 27, 18, 14, 1, 8, 20, 15, 13];
ned = 3;

%% loop over all elements
for e = 1:nel

    % quad rule for each element type
    el_quad = quad_rules{ eltype(e) };

    % Get element info:
    nen_e = nen(eltype(e));
    nee = ned*nen_e;
    A = IEN(1:nen_e,e);
    xe = x(A);
    ye = y(A);
    ze = z(A);
    ue = qn(ID(1,A));
    ve = qn(ID(2,A));
    we = qn(ID(3,A));

    if eltype(e) == 11
        % 10-Node tetrahedron
        [com_e, mass_e] = el11_COM(xe, ye, ze, ue, ve, we, rho(e), el_quad.nt, el_quad.xi, el_quad.eta, el_quad.zeta, el_quad.w);

    elseif eltype(e) == 12
        % 27-Node hexahedron
        [com_e, mass_e] = el12_COM(xe, ye, ze, ue, ve, we, rho(e), el_quad.nt, el_quad.xi, el_quad.eta, el_quad.zeta, el_quad.w);
       
    else
        error('Error: unknown element type');
    end

    moment_b = moment_b + mass_e*com_e;
    mass_b = mass_b + mass_e;

end

body_COM = moment_b/mass_b;
body_mass = mass_b;
