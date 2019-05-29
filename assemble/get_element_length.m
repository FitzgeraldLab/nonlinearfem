function lengths = get_element_length(e,x,y,z,qi,eltype,IEN,ID,quad_rules,nen_list)


nen = nen_list(eltype(e));

a = 1:nen;
A = IEN(a,e);

xe = x(A);
ye = y(A);
ze = z(A);

ue = qi(ID(1,A));
ve = qi(ID(2,A));
we = qi(ID(3,A));

% get the quad rules for a line (make sure it is of sufficiently high in
% order)
el_quad = quad_rules{1};
if isempty(el_quad)
    error('Quad rule not loaded.  Make sure to include ''1'' in the list of element types to call to ''set_integration_rules''');
end

if eltype(e) == 9
    % 6 node triangle
    lengths = el9_lengths( xe, ye, ze, ue, ve, we, ...
        el_quad.nt, el_quad.xi, el_quad.w);
    
elseif eltype(e) == 10
    % 9 node quad
    lengths = el10_lengths( xe, ye, ze, ue, ve, we, ...
        el_quad.nt, el_quad.xi, el_quad.w);
elseif eltype(e) == 12
    % 27 node quad: calculate the length of midplane
    lengths = el12_lengths_midplane( xe, ye, ze, ue, ve, we, ...
        el_quad.nt, el_quad.xi, el_quad.w);
else
    
    error('element length of eltype(%d) = %d is unknown', e, eltype(e));
    
end

