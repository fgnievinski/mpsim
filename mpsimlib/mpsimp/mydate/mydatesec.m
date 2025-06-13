function out = mydatesec (num, is_diff)
%MYDATESEC: Convert epoch interval to (decimal) seconds.
    %if (nargin < 2) || isempty(is_diff),  is_diff = false;  end  % WRONG!
    if (nargin < 2) || isempty(is_diff),  is_diff = true;  end
    if (size(num,2) > 1),  vec = num;  num = mydatenum(vec, is_diff);  end
    %[factor0, num0] = mydatebase (is_diff);  % WRONG!
    [~, num0, ~, ~, factor0] = mydatebase (is_diff);
    out = num;
    if (num0 ~= 0),  out = out - num0;  end
    if (factor0 ~= 1),  out = out .* factor0;  end
end

%!test
%! sec = 100 * rand();
%! vec = [0 0 0  0 0 sec];
%! num = mydatenum (vec, true)
%! sec2 = mydatesec (num, true);
%! num2 = mydateseci (sec, true);
%! [sec, sec2, sec2-sec]
%! [num, num2, num2-num]
%! myassert(sec2, sec, -sqrt(eps()))
%! myassert(num2, num, -sqrt(eps()))

