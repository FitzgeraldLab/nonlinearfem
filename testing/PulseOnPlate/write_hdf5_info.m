function write_hdf5_info(hfile, ...
    ... % msh, ...
    x, y, z, ...
    nel, eltype, IEN, ID, LM, neq, gg, nee, ng, r1, ...
    E, nu, rho, ...
    matype, ...
    quad_rules, ...
    kappa_m, kappa_k, ...
    rho_inf,...
    ps_IEN, ps_eltype, ps_nel)



nnp = length(x);
dataset_name = '/mesh/x';
h5create(hfile, dataset_name, nnp);
h5write(hfile, dataset_name, x);

dataset_name = '/mesh/y';
h5create(hfile, dataset_name, nnp);
h5write(hfile, dataset_name, y);

dataset_name = '/mesh/z';
h5create(hfile, dataset_name, nnp);
h5write(hfile, dataset_name, z);

dataset_name = '/mesh/nel';
h5create(hfile, dataset_name, 1);
h5write(hfile, dataset_name, nel);



