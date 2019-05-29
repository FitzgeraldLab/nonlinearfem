function [Kfp, Qfp] = assemble_NormalSurfaceLoads(ned, nen, nnp, eltype_load,...
    x, y, z, IEN_load, ID, qi, quad_rules, el_list, pressure_list)


%%
totaldofs = ned*nnp;

%%
nee = max(ned*nen(eltype_load(el_list)));
n_el_list = length(el_list);
ntriplets = nee*(nee*n_el_list);
I = zeros(ntriplets,1);
J = zeros(ntriplets,1);
X = zeros(ntriplets,1);

Iq = zeros(nee*n_el_list,1);
Xq = zeros(nee*n_el_list,1);

%% loop over all elements
idx_nq = 0;
idx_n  = 0;
for e1 = 1:length(el_list)
    
    e = el_list(e1);
    pressure = pressure_list(e1);
    
    nen_e = nen(eltype_load(e));
    
    % quad rule for each element type
    el_quad = quad_rules{ eltype_load(e) };
    
    % setup xe ye ze, faster
    A = IEN_load(1:nen_e,e);
    xe = x(A);
    ye = y(A);
    ze = z(A);
    ue = qi(ID(1,A));
    ve = qi(ID(2,A));
    we = qi(ID(3,A));
    
    if( eltype_load(e) == 10 )
        % 9-Node Quad
        [ke, Qe] = el10_compute_normalsurfaceload(xe,ye,ze,ue,ve,we, el_quad.nt, el_quad.xi, el_quad.eta, el_quad.w, pressure);
        
    else
        error('Error: element type <%d> is not implemented', eltype_load(e));
    end
    
    
    % add into global stiffness matrix internal force vector
    for a1 = 1:nen_e
        for i1 = 1:ned
            %p1 = ned*(a1-1)+i1;
            p1 = a1 + nen_e*(i1-1);
            idx1 = ID(i1,IEN_load(a1,e));
            
            idx_nq = idx_nq + 1;
            Iq(idx_nq) = idx1;
            Xq(idx_nq) = Qe(p1);
            
            for a2 = 1:nen_e
                for i2 = 1:ned
                    %p2 = ned*(a2-1)+i2;
                    p2 = a2 + nen_e*(i2-1);
                    idx2 = ID(i1,IEN_load(a1,e));
                    idx_n = idx_n + 1;
                    I(idx_n) = idx1;
                    J(idx_n) = idx2;
                    X(idx_n,1) = ke(p1,p2);
                    %K(idx1,idx2) = K(idx1,idx2) + ke(p1,p2);
                end
            end
        end
    end
    
end

%%

Qfp = sparse(Iq,1,Xq,totaldofs,1);
Kfp = sparse(I,J,X,totaldofs,totaldofs);

