function rmse = nanrmse (obs, dim, ignore_nans, robustify)
%NANRMSE  Root-mean-squared error, ignoring NaNs.
    if (nargin < 2),  dim = [];  end
    if (nargin < 3),  ignore_nans = [];  end
    if (nargin < 4) || isempty(robustify),  robustify = false;  end
    if robustify
        rmse = nanrmser (obs, dim, ignore_nans);
        return;
    end
    [dim, ignore_nans] = nanstdur_aux (obs, dim, ignore_nans);
    if ignore_nans,  mymean = @nanmean;  else  mymean = @mean;  end
    %if ignore_nans,  myvar  = @nanvar;   else  myvar  = @var;   end
    
    %y = sqrt(mymean(x, dim).^2 + myvar(x, 1, dim));
    rmse = sqrt(mymean(obs.^2, dim));  % simpler
end

