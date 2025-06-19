function [wmean, n, std2, std3, std4] = nanmeanu (obs, std, dim, ignore_nans, detrendit)
%NANMEANU  Uncertainty-weighted mean, ignoring NaNs.
    if (nargin < 2),  std = [];  end
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    if (nargin < 5),  detrendit = [];  end
    [dim, ignore_nans, detrendit, std] = nanstdur_aux (obs, ...
     dim, ignore_nans, detrendit, std);
    if ignore_nans
        mymean = @nanmean;
        mysum  = @nansum;     
        mysize = @numnonnan;  
    else
        mymean = @mean;  
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
        temp = times_all(obs, w);
        %wmean = mysum(temp, dim);  % yields 0 for empty obs.
        wmean = mymean(times_all(temp, n), dim);  % yields NaN for empty obs.
    else
        wmean = NaN(size(n));
    end

    if (nargin < 3),  return;  end
    if detrendit
        resid = minus_all(obs, wmean);
    else
        resid = obs;
    end
    temp = times_all(resid.^2, varinv);
    %var3 = mymean(temp, dim);
    var3 = divide_all(mysum(temp, dim), (n-1));
    std3 = sqrt(var3);
    
    if (nargin < 4),  return;  end
    var4 = mymean(var, dim);
    %var4 = divide_all(mysum(var, dim), (n-1));
    std4 = sqrt(var4);
end

%!test
%! for m=0:5
%! for n=0:5
%! %for m=2
%! %for n=2
%!   s0 = rand();
%!   s = repmat(s0, [m n]);
%!   y = randn(m,n)*s0;
%!   [meanw1, s2w1] = nanmeanu(y, s, 1)
%!   [meanw2, s2w2] = nanmeanu(y, s, 2);
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
