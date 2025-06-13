function [rmss, num_obs] = nanrmssur (num_params, resid, std, dim, ignore_nans, robustify)
%NANRMSSUR  Square-root of reduced chi-squared or parameter-scaled uncertainty-weighted root-mean-squared error, robust against outliers, ignoring NaNs.
% 

  if (nargin < 3) || isempty(std),  std = 1;  end
  if (nargin < 4) || isempty(dim),  dim = finddim(resid);  end
  if (nargin < 5) || isempty(ignore_nans),  ignore_nans = true;  end
  if (nargin < 6) || isempty(robustify),    robustify   = true;  end
  if isempty(num_params),  num_params = 1;  end
  if      robustify &&  ignore_nans,  myrms = @nanrmser;
  elseif ~robustify &&  ignore_nans,  myrms = @nanrmse;
  elseif  robustify && ~ignore_nans,  myrms = @rmser;
  elseif ~robustify && ~ignore_nans,  myrms = @rmse;
  end
  rmss = myrms(resid./std, dim);
  num_obs = numnonnan(resid, dim);
  if (num_params <= 1),  return;  end
  if (num_obs < num_params) || (num_obs < 1),  return;  end
  temp = sqrt( (num_obs - 1) ./ (num_obs - num_params) );
  rmss = times_all(rmss, temp);
end

