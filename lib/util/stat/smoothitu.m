function [iavg, itime, istd_obs, istd_avg, inum, istd_inp, istd_scale, resid] = smoothitu (...
time, obs, std, dt, itime, ...
ignore_self, robustify, detrendit, ...
rigorous_residuals, interp_method)
%SMOOTHITU  Uncertainty-weighted running average.

  if (nargin < 5),  itime = [];  end
  if (nargin < 6) || isempty(ignore_self),  ignore_self = false;  end
  if (nargin < 7) || isempty(robustify),  robustify = false;  end
  if (nargin < 8) || isempty(detrendit),  detrendit = true;  end
  if (nargin < 9) || isempty(rigorous_residuals),  rigorous_residuals = true;  end
  if (nargin <10) || isempty(interp_method),  interp_method = 'linear';  end
  if isscalar(robustify),  robustify(2) = true;  end

  time = colvec(time);
  obs = colvec(obs);
  std = colvec(std);
  if isempty(std),  std = 1;  end
  if isscalar(std),  std = repmat(std, size(time));  end
  assert(numel(std) == numel(time))
  assert(numel(obs) == numel(time))
  assert(all((std >= 0) | isnan(std)))
  if isempty(time)
    iavg = time;
    itime = time;
    istd_obs = time;
    istd_avg = time;
    inum = time;
    istd_scale = time;
    resid = time;
    return;
  end

  dim = 1;
  ignore_nans = [];
  h = @(obs, std, detrendit, robustify) nanstdur (obs, std, dim, ignore_nans, detrendit, robustify);
  g = @(in, detrendit, robustify) deal_out2vec(@() h(in(:,1), in(:,2), detrendit, robustify), 6);

  f = @(in) g(in, detrendit, robustify(1));
  in = [obs std];
  [out, itime] = smoothit(time, in, dt, itime, f, [], [], ignore_self);
  [istd_obs, istd_avg, istd_scale, istd_inp, inum, iavg] = deal2(out, 1);
  %figure, hold on, plot(x, y, '.k'), plot(xi, ymi, '-r'), plot(xi, ymi+s3, '-b')

  %return
  if (nargout < 3) || ~rigorous_residuals,  return;  end
  if isequaln(time, itime) || isscalar(itime)
    avg = iavg;
  else
    avg = interp1nan(itime, iavg, time, interp_method);
  end
  resid = obs - avg;

  f = @(in) g(in, false, robustify(2));
  in = [resid std];
  out = smoothit(time, in, dt, itime, f, [], [], ignore_self);
  [istd_obs, istd_avg, istd_scale, istd_inp] = deal2(out, 1);
end
