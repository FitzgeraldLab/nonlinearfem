function [qi, qdi, qddi, iter] = genAlpha_step_forcing(t,dt,qn,qdn,qddn, ...
    M, M1, D, D1, rho_inf, ...
    LM, ned, nen, nnp, nel, eltype, matype,...
    KK_idx_I, KK_idx_J,...
    E, x, y, z, IEN, ID, quad_rules, nu,...
    freefree_range, freefix_range,...
    A_kineForcing, kineForcingFcn, forcingFcn, f_IEN, f_eltype, f_nel)

%% prep
alpha_m = (2*rho_inf - 1)/(rho_inf + 1);
alpha_f = rho_inf/(rho_inf + 1);
beta    = 1/4*( 1 - alpha_m + alpha_f )^2;
gamma   = 1/2 - alpha_m + alpha_f;

iter.max_steps = 200;
iter.rel_tol = 1e-12;
iter.equil = 0;
iter.i = 0;

%% t(n)
qi = qn;
qdi = qdn;
qddi = qddn;

[qi, qdi, qddi] = setKinematics( t, qi, qdi, qddi, A_kineForcing, ID, kineForcingFcn);

[~,f_int_n] = assemble_K(LM, ned, nen, nnp, nel, eltype, matype,...
    KK_idx_I, KK_idx_J,...
    E, x, y, z, IEN, ID, qn, quad_rules, nu);
f_int_n = f_int_n(freefree_range);

[f_ext_n] = assemble_SurfaceLoads(ned, nen, nnp, f_eltype,...
    x, y, z, f_IEN, ID, qi, quad_rules, 1:f_nel, forcingFcn, t);
f_ext_n = f_ext_n(freefree_range);

%% t(n+1)

t = t + dt;
[qi, qdi, qddi] = setKinematics( t, qi, qdi, qddi, A_kineForcing, ID, kineForcingFcn);

walltime1 = tic();
while iter.equil == 0
    
    iter.i = iter.i + 1;
    
    % assemble the stiffness/Internal force
    [K,f_int_i] = assemble_K(LM, ned, nen, nnp, nel, eltype, matype,...
        KK_idx_I, KK_idx_J,...
        E, x, y, z, IEN, ID, qi, quad_rules, nu);
    K1 = K(freefree_range,freefree_range);
    f_int_i = f_int_i(freefree_range); % since free response
    
    % assemble the Tangent Stiffness Matrix
    Kt = (1-alpha_f)*K1 + (1-alpha_m)/beta/dt^2*M1 + (1-alpha_f)*gamma/beta/dt*D1;
    
    % assemble the external forces
    [f_ext_i] = assemble_SurfaceLoads(ned, nen, nnp, f_eltype,...
    x, y, z, f_IEN, ID, qi, quad_rules, 1:f_nel, forcingFcn, t);
    f_ext_i = f_ext_i(freefree_range);
    
    % assemble the RHS
    a1 = (1.-alpha_m)/(beta*dt^2);
    a2 = -(1.-alpha_m)/(beta*dt);
    a3 = -(1.-alpha_m-2*beta)/(2.*beta);
    b1 = ( (1.-alpha_f)*gamma )/( beta * dt);
    b2 = -( (1.-alpha_f)*gamma - beta )/beta;
    b3 = -( gamma - 2*beta)*(1.-alpha_f)*dt/(2.*beta);
    
    RHS = (1-alpha_f)*f_int_i + alpha_f*f_int_n;
    RHS = RHS - (1-alpha_f)*f_ext_i - alpha_f*f_ext_n;
    RHS = RHS + M1*( a1*( qi(freefree_range) - qn(freefree_range) ) + a2*qdn(freefree_range) + a3*qddn(freefree_range) );
    RHS = RHS + D1*( b1*( qi(freefree_range) - qn(freefree_range) ) + b2*qdn(freefree_range) + b3*qddn(freefree_range) );
    
    RHS = assemble_kinematicForcing(RHS, qdi, qddi, qdn, qddn, ...
        M, D, freefree_range, freefix_range, alpha_f);
    
    Dq = -Kt\RHS;
    
    % update qi
    qi(freefree_range) = qi(freefree_range) + Dq;
    
    % Convergence Check
    %rel_error = gamma*norm(Dq,2)/beta/dt;
    rel_error = norm(Dq,2);
    iter.rel_error(iter.i) = rel_error;
    
    if rel_error <= iter.rel_tol
        wall_time = toc(walltime1);
        fprintf('t= %6.3e, i=%4d, error= %.1e, wall step time = %.3e\n', t, iter.i , rel_error, wall_time);
        iter.equil = 1;
        
    elseif iter.i >= iter.max_steps
        iter.equil = -1;
        error('Solution has not convergered at:\tt = %.f\n\ti = %d\n', t, iter.i);
    end
    
end


% update velocity
qdi(freefree_range) = gamma/beta/dt*( qi(freefree_range) - qn(freefree_range) ) - (gamma-beta)/beta*qdn(freefree_range) - (gamma - 2*beta)/2/beta*dt*qddn(freefree_range);

% update acceleration
qddi(freefree_range) = 1/beta/dt^2*( qi(freefree_range) - qn(freefree_range) ) - 1/beta/dt*qdn(freefree_range) - (1-2*beta)/2/beta*qddn(freefree_range);

% swap old values
% qn      = qi;
% qdn     = qdi;
% qddn    = qddi;
% f_int_n = f_int_i;

end
