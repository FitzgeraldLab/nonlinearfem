function [qn, qdn, qddn] = setKinematics( tn, qn, qdn, qddn, A_in, ID, kineForcingFcn)

std_element_defs;

% build kinematics
[w,wd,wdd] = kineForcingFcn(tn);

% ID(i,A)
if nargout == 1
    for a = 1:length(A_in)
        A = A_in(a);
        p = ID(1:ned,A);
        qn(p) = w(:);
    end
elseif nargout == 2
    for a = 1:length(A_in)
        A = A_in(a);
        p = ID(1:ned,A);
        qn(p) = w(:);
        qdn(p) = wd(:);
    end
    
elseif nargout == 3
    for a = 1:length(A_in)
        A = A_in(a);
        p = ID(1:ned,A);
        qn(p) = w(:);
        qdn(p) = wd(:);
        qddn(p) = wdd(:);
    end
    
end