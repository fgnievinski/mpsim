function [y, a, b, c] = normalize (x, prc, ignore_infinite)
    if (nargin < 2) || isempty(prc),  prc = 100;  end
    if (nargin < 3) || isempty(ignore_infinite),  ignore_infinite = true;  end
    if ignore_infinite,  x(~isfinite(x)) = NaN;  end
    if isscalar(x),  y = x;  return;  end
    if (prc == 100)
        a = min(x(:));
        b = max(x(:));
    else
        temp = (100 - prc) / 2;
        [a, b] = deal2(prctile(x(:), [temp, 100-temp]));
    end
    c = b - a;
    y = (x - a) ./ c;
    if (prc == 100)
        return
    else
        y(y<0) = 0;
        y(y>1) = 1;
    end
end

%!test
%! n = 1 + ceil(10*rand);
%! x = rand(n,1);
%! y = sort(normalize(x));
%! myassert(min(y), 0);
%! myassert(max(y), 1);

%!test
%! x = rand;
%! myassert(normalize(x), x)

