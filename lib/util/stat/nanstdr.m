function [std, k] = nanstdr (obs, dim, ignore_nans, detrendit)
%NANSTDR  Standard deviation, robust against outliers, ignoring NaNs.
% 
% See also: NANSTD, STDR, STD.

    if (nargin < 2),  dim = [];  end
    if (nargin < 3),  detrendit = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    [dim, ignore_nans, detrendit] = nanstdur_aux (obs, dim, ignore_nans, detrendit);
    if ignore_nans,  mymedian = @nanmedian;  else  mymedian = @median;  end
    if detrendit
        obsm = mymedian(obs, dim);
        obs = minus_all(obs, obsm);
        %obs = obs - obsm;  % WRONG!
    end
    mad = mymedian(abs(obs), dim);
    k = 1;
    if ~is_uniform(abs(obs))
      % (asuming normal distribution)
      k = 1.4826;  % (see <http://en.wikipedia.org/wiki/Median_absolute_deviation>.)
    end
    std = k * mad;
end

%!test
%! obs = [1 2 NaN];
%! myassert(isnan(stdr(obs)))
%! myassert(~isnan(nanstdr(obs)))

%!test
%! % nanstdr()
%! test stdr

