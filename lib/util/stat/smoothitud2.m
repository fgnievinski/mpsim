function [istd_scale, itime, idof, istd_inp, istd_obs, istd_avg, iavg] = smoothitud2 (...
num_params, ...
time, resid, std, dof, dt, itime, ...
ignore_self, robustify)
%SMOOTHITUD2  Second-order uncertainty-weighted running average, with varying degree of freedom.

    if (nargin < 7),  itime = [];  end
    if (nargin < 8),  ignore_self = false;  end
    if (nargin < 9),  robustify = false;  end
    
    detrendit = false;
    rigorous_residuals = false;
    interp_method = [];
    idof_method = 2;
    [iavg, itime, istd_obs, istd_avg, idof, istd_inp, istd_scale] = smoothitud (...
        time, resid, std, dof, dt, itime, ...
        ignore_self, robustify, detrendit, ...
        rigorous_residuals, interp_method, idof_method);
      
    if isempty(num_params) || (num_params == 1),  return;  end
    num_obs = idof + 1;
    temp = (num_obs - 1) ./ (num_obs - num_params);
    temp(temp <= 0) = 1;
    istd_scale = istd_scale .* sqrt(temp);
end
