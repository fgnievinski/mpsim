function [iparam, icov_param, effect, ...  
iavg, itime, istd_obs, istd_avg, idof, istd, istd_scale, ...
 avg,  time,  std_obs,  std_avg,  dof2, std2,  std_scale] = smoothitup (...
get_jacob, extra, ...
time, obs, std, dof, dt, itime, ...
ignore_self, robustify, detrendit, ...
rigorous_residuals, interp_method, idof_method, std_inp_min)
%SMOOTHITUP  Uncertainty-weighted running adjustment (with non-trivial Jacobian).

% Note: the function handle get_jacob outputs the Jacobian matrix and has
% three input arguments: average epoch (scalar), observation epochs
% (vector), and extra data necessary for its evaluation. For a trivial
% Jacobian (column vector of ones), smoothitup.m is equivalent to
% smoothitu.m. For interpolation, the first input argment might be a vector
% of the same size as the second argument.

  if (nargin <  8),  itime = [];  end
  if (nargin <  9) || isempty(ignore_self),  ignore_self = false;  end
  if (nargin < 10) || isempty(robustify),  robustify = false;  end
  if (nargin < 11) || isempty(detrendit),  detrendit = true;  end  %#ok<NASGU> (keep interface)
  if (nargin < 12) || isempty(rigorous_residuals),  rigorous_residuals = true;  end
  if (nargin < 13) || isempty(interp_method),  interp_method = 'linear';  end
  if (nargin < 14),  idof_method = [];  end
  if (nargin < 15),  std_inp_min = [];  end
  if isscalar(robustify),  robustify(2) = true;  end

  [std, dof, dof_original] = smoothitudc_dof (std, dof); %#ok<ASGLU>
  % avoid unrealistically small std., that would result is exceedingly large weights:
  if ~isempty(std_inp_min),  std = max(std, std_inp_min);  end

  obs(isnan(std)) = NaN;
  in = [obs, std, extra];
  
  wrapper2 = @(varargin) wrapper(varargin{:}, get_jacob, robustify(1));
  ignore_nans = true;
  input_x = true;
  return_as_cell = [];
  verbose = [];
  force_row_input_if_scalar = true;
  [out, itime] = smoothit (time, in, dt, itime, wrapper2, ...
    ignore_nans, input_x, ignore_self, return_as_cell, verbose, ...
    force_row_input_if_scalar);
  
  num_params = size(get_jacob(0, 0, zeros(1,size(extra,2))), 2);
  out = mat2cell(out, numel(itime), [num_params, num_params^2, 1, 1, 1]);
  [iparam, icov_param_flat, istd_scale, istd, inum] = out{:};
  icov_param = frontal_deflatten_cov (icov_param_flat);
  
  if (nargout < 3);  return;  end

  idof = smoothitudc_idof (time, dof_original, itime, inum, dt, idof_method, ignore_self);
  
  myinterp1 = @(in) interp1nan(itime, in, time, interp_method);
  param = myinterp1(iparam);
  jacob = get_jacob (time, time, extra);
  effect = jacob .* param;
  avg = sum(effect, 2);
  %avg = jacob * param;  % WRONG! param is not a vector.
  %resid = obs - avg;  % WRONG!
  resid = avg - obs;
  
  if rigorous_residuals
    istd_scale_prelim = istd_scale;
    %istd_scale = smoothitud2 (num_params, ...
    istd_scale = smoothitud2b (num_params, ...
      time, resid, std,   1, dt, itime, ignore_self, robustify(2));
    istd_scale_ratio = istd_scale ./ istd_scale_prelim;
    icov_param = frontal_times(icov_param, frontal_pt(istd_scale_ratio.^2));
    %icov_param = frontal_times(icov_param, frontal_pt(istd_scale_ratio));  % WRONG!
  end

  %iextra = extra;  % WRONG! (extra can't always be interpolated)
  %iextra = [];  % WRONG! get_jacob might expect non-empty input.
  iextra = NaN(size(itime,1), size(extra,2));  % input at least of right size.
  ijacob = get_jacob (itime, itime, iextra);
  ijacob = zeronan(ijacob);
  ieffect = ijacob .* iparam;
  iavg = sum(ieffect, 2);
  ijacob2 = ijacob;
  %ijacob2 = linsolve_pre(istd, ijacob);  % EXPERIMENTAL
  ivar_avg = frontal_jacob2var_pt(ijacob2, icov_param, 'symm');
  istd_avg = sqrt(ivar_avg);
  istd_obs = sqrt(istd_scale.^2 + ivar_avg) .* istd;  % see nanstdur
  %istd_obs = istd_obs ./ istd_scale;  % see nanstdur
  
  if (nargout < 9);  return;  end
  %TODO: use myinterp1std = @(in) exp(myinterp1(log(in)));
  std_scale = myinterp1(istd_scale);
  dof2 = myinterp1(idof);
  std_obs = myinterp1(istd_obs);
  std_avg = myinterp1(istd_avg);
  std2 = myinterp1(istd);
  return  
  %std2 = std;
  cov_param_flat = myinterp1(icov_param_flat);
  cov_param = frontal_deflatten_cov (cov_param_flat);
  jacob2 = jacob;
  %jacob2 = linsolve_pre(std, jacob);  % EXPERIMENTAL
  var_avg = frontal_jacob2var_pt(jacob2, cov_param, 'symm');
  std_avg = sqrt(var_avg);
  std_obs = sqrt(std_scale.^2 + var_avg) .* std2;  % see nanstdur
  %std_obs = std_obs ./ std_scale;  % see nanstdur
end

%%
function out = wrapper (epoch, in, epochk, get_jacob, robustify)
  obs = in(:,1);
  std = in(:,2);
  extra = in(:,3:end);
  jacob = get_jacob (epochk, epoch, extra);
  
  [num_obs, num_params] = size(jacob);
  %if (num_obs < num_params)
  if (num_obs < (num_params+1))
    out = NaN(1,num_params+num_params^2+3);
    return
  end

  if robustify(1),  mylinsolve = @linsolver;  else  mylinsolve = @linsolve;  end
  if isscalar(robustify),  robustify(2) = robustify(1);  end
  
  [param, cov, resid] = mylinsolve (std, jacob, obs);
  [cov, std_scale, std_obs_prior] = get_stats (cov, resid, std, num_obs, num_params, robustify(2));
  
  out = [rowvec(param), rowvec(cov(:)), std_scale, std_obs_prior, num_obs];
end

%%
function [cov_param, std_scale, std_obs_prior] = get_stats (cov_param_unscaled, resid, std, num_obs, num_params, robustify) %#ok<INUSL>
  std_scale = nanrmssur2(num_params, resid, std, [], [], robustify);
  cov_param = cov_param_unscaled .* std_scale.^2;
  %std_param = sqrt(diag(cov_param));
  std_obs_prior = exp(nanavgr(log(std), [], [], robustify));
  %std_obs_prior = sqrt(nanavgr(std.^2, [], [], robustify));
end

%%
function [x, C, e] = linsolver (s, J, y)
  [J2, y2] = linsolve_pre (s, J, y);
  warn = warning('off', 'stats:statrobustfit:IterationLimit');
  try
    [x, stats] = robustfit (J2, y2, [], [], 'off');
  catch err
    if strcmp(err.identifier, 'stats:robustfit:NotEnoughData')
        [n,m] = size(J);
        x = NaN(m,1);
        C = NaN(m,m);
        if (nargin < 3),  return;  end
        e = NaN(n,1);
        warning(warn)
        return;
    end
  end
  warning(warn)
  C = stats.covb ./ stats.s^2;
  n = numel(x);  if ~isequal(size(C), [n n]),  C = NaN(n,n);  end
  e = linsolve_post (x, J, y);
end

%%
function [x, C, e] = linsolve (s, J, y)
  [J2, y2] = linsolve_pre (s, J, y);
  u = J2'*y2;
  N = J2'*J2;
  %warn = warning('off', 'MATLAB:nearlySingularMatrix');
  C = inv(N);
  %[~, warn_id] = lastwarn();
  %if strcmp(warn_id, 'MATLAB:nearlySingularMatrix'),  keyboard();  end
  %warning(warn)
  x = C * u; %#ok<MINV>  % we need C.
  %x = J \ y;
  e = linsolve_post (x, J, y);
end

%%
function [J2, y2] = linsolve_pre (s, J, y)
  L_inv_diag = 1./s;  %  Linv = diag(L_inv_diag);
  J2 = mtimes_diag(L_inv_diag, J);  % = Linv * J;
  if (nargin < 3),  return;  end
  y2 = mtimes_diag(L_inv_diag, y);  % = Linv * y;
end

%%
function e = linsolve_post (x, J, y)
  e = J*x - y;
end
