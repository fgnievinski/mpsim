% faster linear interpolation and extrapolation.
function yi = interp1lerp (x, y, xi)
  assert(numel(y) == 2)
  dy  = y(2) - y(1);
  dx  = x(2) - x(1);
  dxi = xi   - x(1);
  yi = y(1) + (dy ./ dx) .* dxi;
end

%!test
%! x = rand(1,2);
%! y = rand(1,2);
%! xi = rand(10,1);
%! yi = interp1lerp(x, y, xi);
%! yi2 = interp1(x, y, xi, 'linear', 'extrap');
%! %[yi, yi2, yi2-yi]  % DEBUG
%! myassert(yi, yi2, -sqrt(eps()))  % DEBUG
