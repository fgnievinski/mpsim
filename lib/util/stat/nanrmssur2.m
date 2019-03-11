function rmss2 = nanrmssur2 (num_params, resid, std, dim, ignore_nans, robustify)
  if (nargin < 3),  std = [];  end
  if (nargin < 4),  dim = [];  end
  if (nargin < 5),  ignore_nans = [];  end
  if (nargin < 6) || isempty(robustify),    robustify = true;  end
  if isempty(num_params),  num_params = 1;  end
  rmss = nanrmssur (num_params, resid, std, dim, ignore_nans, false);
  if ~robustify,  rmss2 = rmss;  return;  end
  [rmssr, num_obs] = nanrmssur (num_params, resid, std, dim, ignore_nans, true);
  % combine robust and non-robust reduced chi-squared estimates:
  % (justification?)
  w  = num_params.^2;
  wr = num_obs;
  rmss2sq = (rmss.^2 .* w + rmssr.^2 .* wr) ./ (w + wr);
  rmss2 = sqrt(rmss2sq);
  rmss2 = max(rmss2, rmssr);
end

