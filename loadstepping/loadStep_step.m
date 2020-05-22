function [qi, iter] = loadStep_step(qn, Fext_load, Fext_direction, A_Fext, ...
    LM, ned, nen, nnp, nel, eltype, matype,...
    KK_idx_I, KK_idx_J,...
    E, x, y, z, IEN, ID, quad_rules, nu,...
    freefree_range, freefix_range, neq, gg)

% Solver options:
iter.max_steps = 20;
iter.rel_tol = 1e-6;
iter.equil = 0;
iter.i = 0;
relaxation.flag = true;
relaxation.omega = 1; % 1:Newton's method, 0 < omega < 1 Successive over relaxation

qi = qn;

%%
walltime1 = tic();
while iter.equil == 0
    
    iter.i = iter.i + 1;
    
    % assemble the stiffness/Internal force
    [K,f_int_i] = assemble_K(LM, ned, nen, nnp, nel, eltype, matype,...
        KK_idx_I, KK_idx_J,...
        E, x, y, z, IEN, ID, qi, quad_rules, nu);
    Kt = K(freefree_range,freefree_range);
    f_int_i = f_int_i(freefree_range); % since free response
        
    %% assemble the RHS
    % $ RHS = -f_{int} + F_{ext} - K_{fr}g $
    
    % Move Internal forces to rhs:
    RHS = -f_int_i;
    
    % External Forcing at specific nodes:
    for j = 1:length(A_Fext)
        P = ID(Fext_direction, A_Fext(j) );
        if P <= neq % bounds check to only load DOF and not boundaries
            RHS(P)= RHS(P) + Fext_load;
        end
    end

    % Displacement BC's output with BC's
    RHS = RHS - K(freefree_range, freefix_range)*gg';
    
    % Solve
    Dq = Kt\RHS;
    
    % update qi
    if relaxation.flag
        % This can help stabilize things by slowing down the convergence on
        % purpose.
        omega = relaxation.omega;
        qi(freefree_range) = (1-omega)*qi(freefree_range) + omega*Dq;
        
    else
        qi(freefree_range) = qi(freefree_range) + Dq;
    end
    
    % Convergence Check
    rel_error = norm(Dq,2);
    iter.rel_error(iter.i) = rel_error;
    
    if rel_error <= iter.rel_tol
        wall_time = toc(walltime1);
        fprintf('step= %6d, i=%4d, error= %.1e, wall step time = %.3e\n', Fext_load, iter.i , rel_error, wall_time);
        iter.equil = 1;
        
    elseif iter.i >= iter.max_steps
        iter.equil = -1;
        error('Solution has not convergered at:\n\tstep = %.d\n\ti = %d\n', Fext_load, iter.i);
    end
    
end


end

