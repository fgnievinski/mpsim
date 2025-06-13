func = 'myprofile_storage';
thetitle = {'Triangular Matrix,' 'Real, Double Precision'};

%func = 'myprofile_chol';
%thetitle = 'Cholesky';

%func = 'myprofile_linsolve';
%thetitle = 'Solution of a linear system';

order_opt.step_percent = 5;
order_opt.step_min = 500;
order_opt.max = Inf;

pack
p_packed = myprofile (func, 'packed', order_opt);

p_full = [];    
pack
p_full = myprofile (func, 'full', order_opt);

p_sparse = [];
pack
p_sparse = myprofile (func, 'sparse', order_opt);

plot_myprofile (thetitle, p_full, p_sparse, p_packed);
