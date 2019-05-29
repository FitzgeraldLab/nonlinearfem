function [ID, LM, neq, gg, nee, ng, free_range, freefix_range, nelt] = build_mesh(nnp, IEN, g_list, nen, ned, nel, eltype, fix)
% generalized from code used by T. Fitzgerald in ENME674, Spring 2008

%%
neq = 0;
count = 0;

%% compute ng:
ng = full(sum(sum(fix>0)));

%% construct ID

ID = zeros(ned,nnp);
totaldof = ned*nnp;

% loop over all nodes
if( nnz(fix) > 0 )
    for  A = 1:nnp
        for i = 1:ned
            % find Essential BC
            if( fix(i,A) == 1 )
                ID(i,A) = totaldof - count;
                count = count + 1;
                gg(count) = g_list(i,A);
            else
                % list no gg's
                neq = neq+1;
                ID(i,A) = neq;
            end
        end
    end
else
    % no constrained coords:
    for  A = 1:nnp
        for i = 1:ned
            neq = neq+1;
            ID(i,A) = neq;
        end
    end
    gg = [];
end

count_ng = length(gg);
if( ng - count_ng ~= 0 )
    fprintf(2,'Error: Number of Essential BC counting does not match.\n');
end

% number of element types
nelt = length(nen);

%% construct LM: the locator matrix

nee = ned*max(nen(eltype));
LM = zeros(nee,nel);

for e = 1:nel
    nen_e = nen(eltype(e));
    for a = 1:nen_e
        for i = 1:ned
            %p = ned*(a-1)+i;
            p = a + nen_e*(i-1);
            LM(p,e) = ID(i,IEN(a,e));
        end
    end
end

%%
%free_range = [ng+1:(nnp*ned)]';
free_range = (1:neq)';
freefix_range = (neq+1:(ng+neq))' ;
