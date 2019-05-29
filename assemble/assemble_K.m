function [K, Qs] = assemble_K(LM, ned, nen, nnp, nel, eltype, matype,...
    KK_idx_I, KK_idx_J,...
    E, x, y, z, IEN, ID, qi, quad_rules, nu)

%%
totaldofs = ned*nnp;
%K = sparse(totaldofs,totaldofs);
%K = spalloc(totaldofs,totaldofs,nnz_KK);
Qs = zeros(totaldofs,1);

%% loop over all elements
X = zeros(size(KK_idx_I));
idx_n = 0;
max_nee = 81;
KE = zeros(max_nee,max_nee,nel);
QE = zeros(max_nee,nel);

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
    qe = [qi(ID(1,A)); qi(ID(2,A)); qi(ID(3,A))] ;

    if eltype(e) == 11

        % 10-Node tetrahedron
        if( matype(e) == 1 )
            % Kirchoff Material
            [Ke, qs] = el11_ke_kirch(Xe, qe,E(e), nu(e), int32(el_quad.nt), el_quad.xi, el_quad.eta, el_quad.zeta, el_quad.w);
        elseif( matype(e) == 2 )
            % Biot Material
            [Ke, qs] = el11_ke_biot(Xe, qe, E(e), nu(e), int32(el_quad.nt), el_quad.xi, el_quad.eta, el_quad.zeta, el_quad.w);
        else
            fprintf(2','Error: unknown material type\n');
            %break
        end

    elseif eltype(e) == 12

        % 27-Node hexahedra
        if( matype(e) == 1 )
            % Kirchoff Material
            [Ke, qs] = el12_ke_kirch(Xe, qe,E(e), nu(e), int32(el_quad.nt), el_quad.xi, el_quad.eta, el_quad.zeta, el_quad.w);
        elseif( matype(e) == 2 )
            % Biot Material
            [Ke, qs] = el12_ke_biot(Xe, qe, E(e), nu(e), int32(el_quad.nt), el_quad.xi, el_quad.eta, el_quad.zeta, el_quad.w);
        else
            fprintf(2','Error: unknown material type\n');
            %break
        end

    else
        error('Error: unknown element type\n');
        %break
    end

    % load for multishapes
    temp = zeros(max_nee,max_nee);
    temp(1:nee,1:nee) = Ke;
    KE(:,:,e) = temp;

    temp = zeros(max_nee,1);
    temp(1:nee) = qs;
    QE(:,e) = temp;

end


%%
% for e = 1:nel
%     % add into global stiffness matrix internal force vector
%     nee = ned*nen(eltype(e));
%     for loop1 = 1:nee
%         i = LM(loop1,e);
%
%         Qs(i) = Qs(i) + QE(loop1,e);
%
%         for loop2 = 1:nee
%             %j = LM(loop2,e);
%             idx_n = idx_n + 1;
%             X(idx_n,1) = KE(loop1,loop2,e);
%             %K(i,j) = K(i,j) + Ke(loop1,loop2);
%         end
%     end
% end

for e = 1:nel
    nee = ned*nen(eltype(e));
    i = LM(1:nee,e);
    Qs(i) = Qs(i) + QE(1:nee,e);
end

for e = 1:nel
    nee = ned*nen(eltype(e));
    for loop1 = 1:nee
        for loop2 = 1:nee
            %j = LM(loop2,e);
            idx_n = idx_n + 1;
            X(idx_n,1) = KE(loop1,loop2,e);
            %K(i,j) = K(i,j) + Ke(loop1,loop2);
        end
    end
end


%%

K = sparse(KK_idx_I,KK_idx_J,X,totaldofs,totaldofs);
