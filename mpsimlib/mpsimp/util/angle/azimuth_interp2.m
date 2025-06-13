function zi = azimuth_interp2 (a, z, ai, method)
  if (nargin < 4),  method = [];  end
  a  = azimuth_range_positive(a);
  ai = azimuth_range_positive(ai);
  a = a(:);  z = z(:);
  a = [a-360; a; a+360];  z = [z; z; z];
  [a, ind] = unique(a);  z = z(ind);
  zi = interp1_fastest(a, z, ai, method);
end

%!test
%! f = @(a) 2*(1+cosd(a));
%! a  = (0:45:360);
%! ai = (0:15:360);
%! z  = f(a);
%! zi = f(ai);
%! zi2 = azimuth_interp2 (a, z, ai, 'spline');
%! figure, pplocal(ai, zi)
%! figure, pplocal(ai, zi2)
