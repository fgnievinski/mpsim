function [...
iavg, itime, istd_obs, istd_avg, idof, istd_inp, istd_scale] ...
= smoothitud (...
time, obs, std, dof, dt, itime, ...
ignore_self, robustify, detrendit, ...
rigorous_residuals, interp_method, idof_method, std_inp_min)
%SMOOTHITUD  Uncertainty-weighted running average, with varying degree of freedom.

    if (nargin < 06),  itime = [];  end
    if (nargin < 07),  ignore_self = [];  end
    if (nargin < 08),  robustify = [];  end
    if (nargin < 09),  detrendit = [];  end
    if (nargin < 10),  rigorous_residuals = [];  end
    if (nargin < 11),  interp_method = [];  end
    if (nargin < 12),  idof_method = [];  end
    if (nargin < 13),  std_inp_min = [];  end

    std = colvec(std);
    dof = colvec(dof);
    if isempty(std),  std = 1;  end
    if isempty(dof),  dof = 1;  end
    if isscalar(std),  std = repmat(std, size(time));  end
    
    [std, dof, dof_original] = smoothitudc_dof (std, dof); %#ok<ASGLU>
    % avoid unrealistically small std., that would result is exceedingly large weights:
    if ~isempty(std_inp_min),  std = max(std, std_inp_min);  end
    
    [iavg, itime, istd_obs, istd_avg, inum, istd_inp, istd_scale] = smoothitu (...
        time, obs, std, dt, itime, ...
        ignore_self, robustify, detrendit, ...
        rigorous_residuals, interp_method);
      
    idof = smoothitudc_idof (time, dof_original, itime, inum, dt, idof_method, ignore_self);
end
