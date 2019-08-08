function [ID, LM, neq, gg, nee, ng, free_range, freefix_range, nelt] = ...
    build_mesh(nnp, ...
    IEN, ...
    g_list, ...
    nen, ...
    ned, ...
    nel, ...
    eltype, ...
    fix, ...
    varargin)

p = inputParser;
addRequired(p,'nnp', @isnumeric);
addRequired(p,'IEN', @isnumeric);
addRequired(p,'g_list', @isnumeric);
addRequired(p,'nen', @isnumeric);
addRequired(p,'ned', @isnumeric);
addRequired(p,'nel', @isnumeric);
addRequired(p,'eltype', @isnumeric);
addRequired(p,'fix', @isnumeric);

addParameter(p, 'resort', false);
addParameter(p, 'resort_fcn', @amd);

% Parse the inputs
parse(p, nnp, IEN, g_list, nen, ned, nel, eltype, fix, varargin{:});
flag.resort = p.Results.resort;
resort_func = p.Results.resort_fcn;

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
freefix_range = (neq+1:(ng+neq))';

%%
if flag.resort
    
    [LM, ID] = renumber_mesh(LM, ned, nen, nnp, nel, eltype, neq, ng, ID, IEN, free_range, resort_func);
    
end

end

%%
function [LM, ID] = renumber_mesh(LM, ned, nen, nnp, nel, eltype, neq, ng, ID, IEN, r1, resortFcn)

[~,I,J,K] = get_nnz_CheckAssembly(LM,ned ,nen ,nnp ,nel, eltype);

%K = sparse(I,J,1,ned*nnp,ned*nnp);

idx = resortFcn(K(r1,r1));
% idx = amd(K(r1,r1));
% idx = symrcm(K(r1,r1));

[LM, ID] = resort_LMID(int32(LM), int32(nen), int32(nnp), int32(nel),...
    int32(eltype), int32(neq), int32(ng), int32(ID), int32(IEN),...
    int32(idx));
end

%%
function [LM, ID] = resort_LMID(LMin, nen, nnp, nel, eltype, neq, ng, IDin, IEN, idx) %#codegen

ned = 3;

LM = LMin;
ID = IDin;

idx = [idx,neq+(1:ng)];
inv_idx = zeros(ned*nnp,1);
inv_idx(idx) = 1:ned*nnp;
for e = 1:nel
    nen_e = nen(eltype(e));
    for a = 1:nen_e
        for i = 1:ned
            p = a + nen_e*(i-1);
            Pnew = inv_idx(LM(p,e));
            
            ID(i,IEN(a,e)) = Pnew;
            LM(p,e) = Pnew;
        end
    end
end
end