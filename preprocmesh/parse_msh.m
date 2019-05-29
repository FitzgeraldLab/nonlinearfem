function [nel, eltype, IEN, idx] = parse_msh(msh, label)

idx = NaN;

% parse body element information:
for i = 1:length(msh)
    if( strcmp( msh{i}.label, label) )
        idx = i;
        break
    end
end

if( isnan(idx) )
    error('Label <%s> not found in msh', label)
end

% total number of elements
nel = msh{idx}.num;

% element types in use:
% eltype(e) = 'element type' number
eltype = msh{idx}.etype;

% define the connectivity IEN:
% IEN(a,e) = A
IEN = msh{idx}.IEN;
