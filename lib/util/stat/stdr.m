function std = stdr (obs, dim, detrendit)
%STDR  Standard deviation, robust against outliers.
% 
% See also: NANSTDR, STD.

    if (nargin < 2),  dim = [];  end
    if (nargin < 3),  detrendit = [];  end
    ignore_nans = false;
    std = nanstdr (obs, dim, ignore_nans, detrendit);
end

%!test 
%! std_true = 100*rand;
%! p = 0.1;  % percentage of outliers.
%! k = 100; % factor to multiply observations to make them outliers.
%! n = 100 + ceil(100*rand);
%! x = std_true .* randn(n,1);
%! std2a = std(x);
%! std2b = stdr(x);
%! 
%! ind = round(linspace(1, n, ceil(n*p)));
%! x(ind) = x(ind) * k;
%! %figure, plot(x, '.')  % DEBUG
%! std3a = std(x);
%! std3b = stdr(x);
%! 
%! temp = [std_true, std2a, std2b, std3a, std3b]';
%! %[temp, temp - std_true]  % DEBUG
%! %temp  % DEBUG
%! myassert(abs(std3b - std_true) < abs(std3a - std_true))

%!test
%! std = stdr (ones(2,3), 1, true);
%! % was trigging bug in 
%! %        resid = minus_all(obs, obs0);
%! %        %resid = obs - obs0;  % WRONG!

%!test
%! std1 = stdr(zeros(1,3));
%! std2 = std(zeros(1,3));
%! myassert(size(std1), size(std2))

%!test
%! std1 = stdr(0);  % scalar
%! std2 = std(0);
%! myassert(size(std1), size(std2))
