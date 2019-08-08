function RHS = assemble_kinematicForcing(RHS, qdi, qddi, ...
    qdn, qddn, M, D, freefree_range, freefix_range, alpha_f)

Mv = M(freefree_range, freefix_range);
Dv = D(freefree_range, freefix_range);

% vdd(n+1)
vddi = qddi(freefix_range);
% vdd(n)
vddn = qddn(freefix_range);
% vd(n+1)
vdi = qdi(freefix_range);
% vd(n)
vdn = qdn(freefix_range);


RHS = RHS + Mv*( (1-alpha_f)*vddi + alpha_f*vddn );
RHS = RHS + Dv*( (1-alpha_f)*vdi  + alpha_f*vdn  );

end