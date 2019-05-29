function [M] = assemble_M(ned, nen, nnp, nel, eltype, ...
                          KK_idx_I, KK_idx_J,...
                          x, y, z, IEN, quad_rules, rho)


%%
totaldofs = ned*nnp;

%% loop over all elements
X = zeros(size(KK_idx_I));
idx_n = 0;
max_nee = 81;
ME = zeros(max_nee,max_nee,nel);

%for e = 1:nel
parfor e = 1:nel

    nen_e = nen(eltype(e));
    nee = ned*nen_e;

    % quad rule for each element type
    el_quad = quad_rules{ eltype(e) };

    % setup xe ye ze, faster
    a = 1:nen_e;
    A = IEN(a,e);
    Xe = [x(A); y(A); z(A)];

    if eltype(e) == 11
        % 10-Node tetrahedron
        [Me] = el11_me(Xe, rho(e), int32(el_quad.nt), el_quad.xi, el_quad.eta, el_quad.zeta, el_quad.w);

    elseif eltype(e) == 12
        % 27-Node hexahedra
        [Me] = el12_me(Xe, rho(e), int32(el_quad.nt), el_quad.xi, el_quad.eta, el_quad.zeta, el_quad.w);

    else
        fprintf(2','Error: unknown element type\n');
        %break
    end

    temp = zeros(max_nee,max_nee);
    temp(1:nee,1:nee) = Me;
    ME(:,:,e) = temp;
end

%%
for e = 1:nel
    nee = ned*nen(eltype(e));
    for loop1 = 1:nee
        for loop2 = 1:nee
            %j = LM(loop2,e);
            idx_n = idx_n + 1;
            X(idx_n,1) = ME(loop1,loop2,e);
            %K(i,j) = K(i,j) + Ke(loop1,loop2);
        end
    end
end


%%

M = sparse(KK_idx_I,KK_idx_J,X,totaldofs,totaldofs);
