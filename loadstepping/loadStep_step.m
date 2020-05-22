function [qi, iter] = loadStep_step(qn, Fext_load, Fext_direction, ...
    LM, ned, nen, nnp, nel, eltype, matype,...
    KK_idx_I, KK_idx_J,...
    E, x, y, z, IEN, ID, quad_rules, nu,...
    freefree_range, freefix_range)

% Solver options:
iter.max_steps = 200;
iter.rel_tol = 1e-12;
iter.equil = 0;
iter.i = 0;

qi = qn;

%%
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
    %TODO:
    
    % assemble the RHS
    %TODO: build RHS with loading
    
    % Solve
    Dq = -Kt\RHS;
    
    % update qi
    qi(freefree_range) = qi(freefree_range) + Dq;
    
    % Convergence Check
    %rel_error = gamma*norm(Dq,2)/beta/dt;
    rel_error = norm(Dq,2);
    iter.rel_error(iter.i) = rel_error;
    
    if rel_error <= iter.rel_tol
        wall_time = toc(walltime1);
        fprintf('step= %6d, i=%4d, error= %.1e, wall step time = %.3e\n', load_increment, iter.i , rel_error, wall_time);
        iter.equil = 1;
        
    elseif iter.i >= iter.max_steps
        iter.equil = -1;
        error('Solution has not convergered at:\tt = %.d\n\ti = %d\n', load_increment, iter.i);
    end
    
end


end

