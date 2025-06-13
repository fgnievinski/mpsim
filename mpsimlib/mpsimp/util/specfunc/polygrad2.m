function [grad_x, grad_y] = polygrad2 (c, x, y, cdx, cdy)
    if (nargin < 4) || isempty(cdx),  cdx = polyder2x (c);  end
    if (nargin < 5) || isempty(cdy),  cdy = polyder2y (c);  end
    grad_x = polyval2 (cdx, x, y);
    grad_y = polyval2 (cdy, x, y);
end

%!test
%! n = 10;
%! x = randint(-1,+1, [n,1]);
%! y = randint(-1,+1, [n,1]);
%! c = randint(-1,+1, [4,3]);
%! [grad_x, grad_y] = polygrad2 (c, x, y);
%! grad_x2 = diff_func(@(x_) polyval2(c, x_, y), x);
%! grad_y2 = diff_func(@(y_) polyval2(c, x, y_), y);
%! [grad_x, grad_x2, grad_x2 - grad_x]  % DEBUG
%! [grad_y, grad_y2, grad_y2 - grad_y]  % DEBUG
%! myassert(grad_x2, grad_x2, -sqrt(eps()))
%! myassert(grad_y2, grad_y2, -sqrt(eps()))

