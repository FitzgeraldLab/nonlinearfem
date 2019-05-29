function [nnz_K,I,J,K] = get_nnz_CheckAssembly(LM,ned ,nen ,nnp ,nel, eltype)


%%
totaldofs = ned*nnp;

%% old slow way
% %% loop over all elements
% K = sparse(totaldofs,totaldofs,round(0.05*totaldofs^2));
% for e = 1:nel
%     
%     nen_e = nen(eltype(e));
%     nee   = nen_e*ned;
%     
%     Ke = ones([nee, nee]);
%     
%     % add into global stiffness matrix internal force vector
%     nee = ned*nen(eltype(e));
%     for loop1 = 1:nee
%         i = LM(loop1,e);
%         
%         for loop2 = 1:nee
%             j = LM(loop2,e);
%             K(i,j) = K(i,j) + Ke(loop1,loop2);
%         end
%     end
% end

%% new fast way
nee = max(ned*nen(eltype));
ntriplets = numel(LM)*nee;
I = zeros(ntriplets,1);
J = zeros(ntriplets,1);
X = zeros(ntriplets,1);

n =0;
n2 =0;
for e = 1:nel
    
    nen_e = nen(eltype(e));
    nee   = nen_e*ned;
       
    % add into global stiffness matrix internal force vector
    for loop1 = 1:nee
        i = LM(loop1,e);
        n2 = n2+1;
        for loop2 = 1:nee
            n = n+1;
            j = LM(loop2,e);
            I(n) = i;
            J(n) = j;
            X(n) = 1;
        end
    end
end
% whos I J X totaldofs

K = sparse(I,J,X,totaldofs,totaldofs);

%% determine number of non-zero elements in K
nnz_K = nnz(K);