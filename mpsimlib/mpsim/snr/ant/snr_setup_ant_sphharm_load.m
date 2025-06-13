function data = snr_setup_ant_sphharm_load (data, n)
    if (nargin < 2) || isempty(n),  n = 10;  end

    data.n = n;
    data.pos_sph = [data.elev data.azim];
    A = sphharm_design (data.pos_sph, n);

    var_constrained = nthroot(eps(), 3);
    var_unconstrained = 1./var_constrained;
    temp = repmat(var_constrained, n+1, n+1);  % constrain all harm.
    temp(:,1) = var_unconstrained;  % uncons. zonal harm.
    
    num_azims = numel(unique_eps(data.azim));
    temp(:,2:min(end,num_azims)) = var_unconstrained;
%     if (num_azims >= 2)
%         temp(2,2) = var_unconstrained;  % uncons. first sectoral harm.
%         temp(:,2) = var_unconstrained;  % uncons. first band of tesseral harm.
%     end
%     if (num_azims >= 3)
%         temp(3,3) = var_unconstrained;  % uncons. second sectoral harm.
%         temp(:,3) = var_unconstrained;  % uncons. second band of tesseral harm.
%     end
      %figure, pcolor(temp), axis image, colorbar  % DEBUG
    CA = diag(temp(tril(true(n+1,n+1))));

    data.final_coeff = sphharm_fit_constrain (data.pos_sph, data.final, n, CA, A);
    data.final_fit = sphharm_eval (data.pos_sph, data.final_coeff, n, A);
    data.original_fit = data.final2original(data.final_fit);
end

