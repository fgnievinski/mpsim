function [...
iavg, itime, iconf_obs, iconf_avg, idof, istd_inp, istd_scale, istd_obs, istd_avg] ...
= smoothitudc (...
time, obs, std, dof, dt, itime, ...
ignore_self, robustify, detrendit, ...
rigorous_residuals, interp_method, idof_method, ...
conf, tail, multiple_correction, std_inp_min)
%SMOOTHITUDC  Uncertainty-weighted running average, returning confidence intervals.

    if (nargin < 06),  itime = [];  end
    if (nargin < 07),  ignore_self = [];  end
    if (nargin < 08),  robustify = [];  end
    if (nargin < 09),  detrendit = [];  end
    if (nargin < 10),  rigorous_residuals = [];  end
    if (nargin < 11),  interp_method = [];  end
    if (nargin < 12),  idof_method = [];  end
    if (nargin < 13),  conf = [];  end
    if (nargin < 14),  tail = [];  end
    if (nargin < 15),  multiple_correction = [];  end
    if (nargin < 16),  std_inp_min = [];  end    

    %%
    [iavg, itime, istd_obs, istd_avg, idof, istd_inp, istd_scale] ...
        = smoothitud (...
        time, obs, std, dof, dt, itime, ...
        ignore_self, robustify, detrendit, ...
        rigorous_residuals, interp_method, idof_method, std_inp_min);
      
    iconf_obs = get_confpred_lim (iavg, istd_obs, idof, conf, tail, 'direct', 'direct', multiple_correction);
    iconf_avg = get_confpred_lim (iavg, istd_avg, idof, conf, tail, 'direct', 'direct', 'none');
    
    %TODO: offer option to return tolerance interval instead
    % [hint: matlab fileexchange (sheffe's formulation)]
    
    return
    %%
    figure %#ok<UNRCH>
    hold on
    plot(time, obs, '.k')
    plot(itime, iavg, '-k')
    plot(itime, iavg+istd_obs, '-r')
    plot(itime, iavg+istd_avg, '-g')
    %plot(itime, istd_avg, '-g')
end

