function [...
iavg, itime, istd_obs, istd_avg, idof, istd_inp, istd_scale] ...
= smoothitud (...
time, obs, std, dof, dt, itime, ...
ignore_self, robustify, detrendit, ...
rigorous_residuals, interp_method, idof_method)
%SMOOTHITUD  Uncertainty-weighted running average, with varying degree of freedom.

    if (nargin < 6),  itime = [];  end
    if (nargin < 7),  ignore_self = [];  end
    if (nargin < 8),  robustify = [];  end
    if (nargin < 9),  detrendit = [];  end
    if (nargin <10),  rigorous_residuals = [];  end
    if (nargin <11),  interp_method = [];  end
    if (nargin <12),  idof_method = [];  end

    std = colvec(std);
    dof = colvec(dof);
    if isempty(std),  std = 1;  end
    if isempty(dof),  dof = 1;  end
    if isscalar(std),  std = repmat(std, size(time));  end
    
    [std, dof, dof_original] = smoothitudc_dof (std, dof); %#ok<ASGLU>
    
    [iavg, itime, istd_obs, istd_avg, inum, istd_inp, istd_scale] = smoothitu (...
        time, obs, std, dt, itime, ...
        ignore_self, robustify, detrendit, ...
        rigorous_residuals, interp_method);
      
    idof = smoothitudc_idof (time, dof_original, itime, inum, dt, idof_method, ignore_self);
end
