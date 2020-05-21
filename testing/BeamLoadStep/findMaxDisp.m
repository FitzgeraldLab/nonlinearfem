%%
function output = findMaxDisp(hfile, ID, n_range)


[ned,nnp] = size(ID);
umax = -10000*zeros(ned,1);
idx_max = zeros(ned,1);
nstep_max = zeros(ned,1);

umin = 10000*zeros(ned,1);
idx_min = zeros(ned,1);
nstep_min = zeros(ned,1);

for n = n_range

    qn = h5read( hfile, sprintf('/%d/qn', n) );
    
    for i = 1:ned
        
        p = ID(i,:);
        
        [localmax,maxidx] = max(qn(p));
        if localmax > umax(i)
            idx_max(i) = maxidx;
            umax(i) = localmax;
            nstep_max(i) = n;
        end
        
        [localmin,minidx] = min(qn(p));
        if localmin < umin(i)
            idx_min(i) = minidx;
            umin(i) = localmin;
            nstep_min(i) = n;
        end
        
    end   
    
end

%%
output.max.val = umax;
output.max.dofNum = idx_max;
output.max.nsteptime = nstep_max;

output.min.val = umin;
output.min.dofNum = idx_min;
output.min.nsteptime = nstep_min;

%% compute box for diverging colormap
% box centered around zero with the longest edge chosen for each direction
output.box.symmetric = max(abs([umax';umin']));

