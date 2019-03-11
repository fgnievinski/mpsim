function [...
iavg, itime, iconf_obs, iconf_avg, idof, istd_inp, istd_scale, istd_obs, istd_avg] ...
= smoothitudc (...
time, obs, std, dof, dt, itime, ...
ignore_self, robustify, detrendit, ...
rigorous_residuals, interp_method, idof_method, ...
conf, tail, multiple_correction)
%SMOOTHITUDC  Uncertainty-weighted running average, returning confidence intervals.

    if (nargin < 6),  itime = [];  end
    if (nargin < 7),  ignore_self = [];  end
    if (nargin < 8),  robustify = [];  end
    if (nargin < 9),  detrendit = [];  end
    if (nargin <10),  rigorous_residuals = [];  end
    if (nargin <11),  interp_method = [];  end
    if (nargin <12),  idof_method = [];  end
    if (nargin <13),  conf = [];  end
    if (nargin <14),  tail = [];  end
    if (nargin <15),  multiple_correction = [];  end

    %%
    [iavg, itime, istd_obs, istd_avg, idof, istd_inp, istd_scale] ...
        = smoothitud (...
        time, obs, std, dof, dt, itime, ...
        ignore_self, robustify, detrendit, ...
        rigorous_residuals, interp_method, idof_method);
      
    iconf_obs = get_pred_lim (iavg, istd_obs, idof, conf, tail, 'direct', 'direct', multiple_correction);
    iconf_avg = get_pred_lim (iavg, istd_avg, idof, conf, tail, 'direct', 'direct', 'none');
    
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

