function [Qfp] = assemble_SurfaceLoads(ned, nen, nnp, eltype_load,...
    x, y, z, IEN_load, ID, qi, quad_rules, el_list, forcing, time)


%%
totaldofs = ned*nnp;

%%
nee = max(ned*nen(eltype_load(el_list)));
n_el_list = length(el_list);

Iq = zeros(nee*n_el_list,1);
Xq = zeros(nee*n_el_list,1);

%% loop over all elements
idx_nq = 0;
for e1 = 1:length(el_list)
    
    e = el_list(e1);
    
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
        [Qe] = el10_compute_forcing(xe,ye,ze,ue,ve,we, el_quad.nt, el_quad.xi, el_quad.eta, el_quad.w, forcing, time);
        
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
           
        end
    end
    
end

%%
Qfp = sparse(Iq,1,Xq,totaldofs,1);

