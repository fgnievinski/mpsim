function [wmean, n, std2, std3, std4] = nanmeanur (obs, std, dim, ignore_nans, detrendit, robustify)
%NANMEANU  Uncertainty-weighted mean, robust against outliers, ignoring NaNs.
% 
% wmean: weighted mean
% n: number of observations (excluding NaNs)
% std2: formal standard uncertainty of the mean (unscaled)
% std3: square-root of reduced chi-squared statistic or a-posteriori variance factor
% std4: typical input or a-priori standard uncertainty of observations

    if (nargin < 2),  std = [];  end
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    if (nargin < 5),  detrendit = [];  end
    if (nargin < 6) || isempty(robustify),  robustify = true;  end
    if isempty(std)
        [wmean, n, std2, std3, std4] = nanmeanr (obs, dim, ignore_nans, detrendit, robustify);
        return;
    end
    [dim, ignore_nans, detrendit, std] = nanstdur_aux (obs, ...
     dim, ignore_nans, detrendit, std);
    if ignore_nans
        mysum  = @nansum;     
        mysize = @numnonnan;  
    else
        mysum  = @sum;   
        mysize = @size;
    end
    
    var = std.^2;
    varinv = 1./var;
    var2inv = mysum(varinv, dim);
    var2 = 1./var2inv;
    std2 = sqrt(var2);

    n = mysize(obs, dim);

    if detrendit
        w = times_all(var2, varinv); % = std2.^2 ./ std.^2;
        wmean = nanavgwr(obs, w, dim, ignore_nans, robustify);
        resid = minus_all(obs, wmean);
    else
        wmean = NaN(size(n));
        resid = obs;
    end

    if (nargout < 4),  return;  end
    std3 = nanrmssur2([], resid, std, dim, ignore_nans, robustify);
    
    if (nargout < 5),  return;  end
    %var4 = nanavgr(var, dim, ignore_nans, robustify);
    var4 = exp(nanavgr(log(var), dim, ignore_nans, robustify));
    std4 = sqrt(var4);
end

%%
function [rmean, n, std2, std3, std4] = nanmeanr (obs, dim, ignore_nans, detrendit, robustify)
%NANMEANR  Average, weighted by sample sizes, robust against outliers, ignoring NaNs.
    [dim, ignore_nans, detrendit] = nanstdur_aux (obs, ...
     dim, ignore_nans, detrendit);
    if ignore_nans,  mysize = @numnonnan;  else  mysize = @size;  end
    
    n = mysize(obs, dim);
    std2 = 1 ./ sqrt(n);
    % TODO: std2 = get_conf_lim(...);

    if detrendit
        rmean = nanavgr(obs, dim, ignore_nans, robustify);
        resid = minus_all(obs, rmean);
    else
        rmean = NaN(size(n));
        resid = obs;
    end
    
    std3 = nanrmssr([], resid, dim, ignore_nans, robustify);
    std4 = 1;
end

%%


%%
%!test
%! for m=0:5
%! for n=0:5
%! %for m=2
%! %for n=2
%!   s0 = rand();
%!   s = repmat(s0, [m n]);
%!   y = randn(m,n)*s0;
%!   [meanw1, s2w1] = nanmeanur(y, s, 1)
%!   [meanw2, s2w2] = nanmeanur(y, s, 2);
%!   mean1 = nanmean (y, 1);  s21 = s0 ./ sqrt(sum(ones(m,n), 1));
%!   mean2 = nanmean (y, 2);  s22 = s0 ./ sqrt(sum(ones(m,n), 2));
%!   [m, n]
%!   [meanw1; mean1; (abs(meanw1 - mean1))]
%!   [meanw2, mean2, (abs(meanw2 - mean2))]
%!   [s2w1; s21; (abs(s2w1 - s21))]
%!   [s2w2, s22, (abs(s2w2 - s22))]
%!   myassert(meanw1, mean1, -sqrt(eps()))
%!   myassert(meanw2, mean2, -sqrt(eps()))
%! end
%! end
