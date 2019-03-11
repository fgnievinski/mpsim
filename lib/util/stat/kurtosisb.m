function kb = kurtosisb (x, dim, p)
%KURTOSISB  Bonnet's kurtosis formulation.
%   For details,  please see:
%       D. G. Bonett (2006): Confidence interval for a ratio of variances
%       in bivariate nonnormal distributions, Journal of Statistical
%       Computation and Simulation, 76:07, 637-644, 
%       doi:10.1080/10629360500107733
%   and
%       D. G. Bonett (2005): Robust confidence interval for a residual
%       standard deviation, Journal of Applied Statistics, 32:10, 
%       1089-1094, doi:10.1080/02664760500165339
% 
%   See also KURTOSIS.

    if isempty(x),  kb = NaN;  return;  end;
    if (nargin < 2) || isempty(dim),  dim = finddim (x);  end
    if (nargin < 3) || isempty(p),  p = 1;  end

    %n = size(x, dim);
    n = sumnonnan(x, dim);
    df = n - p;
    prc = 100 ./ (2 * sqrt(df - 4));
    m = trimmean(x, prc, dim);
    %m = nanmean(x, dim);

    x = bsxfun(@minus, x, m);
    ns2 = nansum(x.^2, dim);
    nm4 = nansum(x.^4, dim);
    %ns = n;
    ns = sum(~isnan(x), dim);
    kb = ns .* nm4 ./ ns2.^2;
end

%!test
%! % for large samples, the two should agree.
%! n = 100;
%! m = 5;
%! ekurt = -2:+2;
%! %ekurt = 0;  % DEBUG
%! kurt = ekurt + 3;
%! num_realiz = 10;
%! for i=1:numel(kurt)
%!   temp = [];
%!   tempb = [];
%!   for j=1:num_realiz
%!     x = pearsrnd(0,1,0,kurt(i),n,m);
%!     temp(end+1,:) = kurtosis (x);
%!     tempb(end+1,:) = kurtosisb (x);
%!   end
%!   k = mean(temp);
%!   kb = mean(tempb);
%!   k - kurt(i)
%!   kb - kurt(i)
%!   max(abs(k - kurt(i)))
%!   max(abs(kb - kurt(i)))
%!   max(abs(k - kb))
%! end

