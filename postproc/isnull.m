function tf = isnull(x)

tf = false;

if( isempty(x) )
    tf = true;
    return
end

if( isnan(x) )
    tf = true;
    return
end