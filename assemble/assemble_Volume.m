function [Volume] = assemble_Volume(IEN, ID, nel, eltype,...
    quad_rules, x, y, z, qi, nen)

%% total volume of the deformed body
Volume  = 0;
eVolume = nan(1,nel);

%% loop over all elements
%parfor e = 1:nel
for e = 1:nel

    % quad rule for each element type
    el_quad = quad_rules{ eltype(e) };

    % Get element info:
    nen_e = nen(eltype(e));
    a = 1:nen_e;
    A = IEN(a,e);
    Xe = [x(A); y(A); z(A)];
    qe = [qi(ID(1,A)); qi(ID(2,A)); qi(ID(3,A))] ;

    if eltype(e) == 11
        % 10-Node tetrahedron
        eVolume(e) = el11_compute_Volume(Xe, qe, int32(el_quad.nt), el_quad.xi, el_quad.eta, el_quad.zeta, el_quad.w);

    elseif eltype(e) == 12
        % 27-Node hexahedra
        eVolume(e) = el12_compute_Volume_mex(Xe, qe, int32(el_quad.nt), el_quad.xi, el_quad.eta, el_quad.zeta, el_quad.w);

    else
        error('Error: unknown element type\n');
    end

end

Volume = sum(eVolume);
