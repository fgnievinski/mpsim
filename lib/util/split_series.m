function [x, argout2] = split_series (dx_tol, x, y)
  assert(isvector(x))
  assert(issorted(x))
  Dx = difffwd(x);
  assert(all(Dx >=0 | isnan(Dx)));
  if (nargin < 1) || isempty(dx_tol),  dx_tol = '10';  end
  if ischar(dx_tol),  dx_tol = num2str(dx_tol) * mode(Dx);  end
  idx = (Dx > dx_tol);
  xn = x(idx) + Dx(idx)./2;
  x = cat(finddim(x), x, xn);
  [x, ind] = sort(x);
  if (nargout < 2),  return;  end
  f = @(in) getel(setel(in, sprintf('end+(1:%d)', sum(idx)), NaN), ind);
  if (nargin < 3)
    argout2 = f;
  else
    y = f(y);
    argout2 = y;
  end
end

%!test
%! x0 = 1:7;
%! x1 = x0;  x1(5) = [];
%! x2 = split_series(1.5, x1);
%! %x0, x1, x2  % DEBUG
%! myassert(x2, x0)

%!test
%! x0 = 1:7;  y0 = x0;
%! x1 = x0;  x1(5) = [];
%! y1 = x0;  y1(5) = [];
%! [x2, y2] = split_series(1.5, x1, y1);
%! x0, x1, x2  % DEBUG
%! y0, y1, y2  % DEBUG
%! %myassert(x2, x0)
%! figure, hold on, plot(x0, y0, 'o-b'), plot(x1, y1, '+-g'), plot(x2, y2, '.-r')
