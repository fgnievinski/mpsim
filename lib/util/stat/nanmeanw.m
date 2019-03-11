function [wmean, ws, n, wm] = nanmeanw (obs, weight, dim, ignore_nans)
%NANMEANW  Weighted mean, ignoring NaNs.
% 
% See also:  NANMEAN.

    if (nargin < 2),  weight = [];  end
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    [dim, ignore_nans, ignore, weight] = nanstdur_aux (obs, ...
     dim, ignore_nans, [],     weight);  %#ok<ASGLU>
   
    if ignore_nans,  mymean = @nanmean;  else  mymean = @mean;  end
    if ignore_nans,  mysum  = @nansum;   else  mysum  = @sum;   end
    
    w = weight;
    ws = mysum(w, dim);
    n = numnonnan(obs, dim);
    %n = size(obs,dim);  % WRONG!
    wm = ws ./ n;
    mw = divide_all(w, wm);
    temp = times_all(obs, mw);
    wmean = mymean(temp, dim);  % yields NaN for empty y.
    %wmean = mysum(temp,  dim);  % older; yields 0 for empty y.
end

%!test
%! for m=0:5
%! for n=0:5
%! %for m=2
%! %for n=2
%!   y = rand(m,n);
%!   w = ones(m,n)*rand();  % random equal weight.
%!   meanw1 = nanmeanw(y, w, 1);
%!   meanw2 = nanmeanw(y, w, 2);
%!   mean1  = nanmean (y, 1);
%!   mean2  = nanmean (y, 2);
%!   [m, n]
%!   [meanw1; mean1; (abs(meanw1 - mean1))]
%!   [meanw2, mean2, (abs(meanw2 - mean2))]
%!   myassert(meanw1, mean1, -sqrt(eps()))
%!   myassert(meanw2, mean2, -sqrt(eps()))
%! end
%! end
