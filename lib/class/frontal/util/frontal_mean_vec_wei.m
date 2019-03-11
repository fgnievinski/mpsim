function [param_avg, cov_avg, std_scale, resid] = frontal_mean_vec_wei (param, cov, is_var_factor_global)
    if (nargin < 3),  is_var_factor_global = [];  end
    
    param = frontal(param, 'pt');
    cov = frontal(cov);
    
    [param_avg, cov_avg, std_scale, resid] = mean_vec_wei (param, cov, is_var_factor_global);

    param_avg = defrontal(param_avg, 'pt');
    cov_avg   = defrontal(cov_avg);
    std_scale = defrontal(std_scale, 'pt');
    resid     = defrontal(resid, 'pt');
end
