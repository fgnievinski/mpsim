function ai = azimuth_interp (t, a, ti, method, extrap)
    if (nargin < 4),  method = [];  end
    if (nargin < 5),  extrap = [];  end
    %ai = interp1(t, a, ti, method, 'extrap');  % WRONG!
    
    % (azimuth is the angle w.r.t. positive y-axis, NOT positive x-axis.)
    y = cos(pi/180*a);  x = sin(pi/180*a);
    %x = cos(pi/180*a);  y = sin(pi/180*a);  % WRONG!

    xi = interp1_fastest(t, x, ti, method, extrap);
    yi = interp1_fastest(t, y, ti, method, extrap);    
    
    ai = 180/pi * atan2(xi, yi);  % angle w.r.t. positive y-axis.
    %ai = 180/pi * atan2(yi, xi);  % angle w.r.t. positive x-axis. WRONG!
    if all(a >= 0),  ai = azimuth_range_positive(ai);  end
end

%!test
%! dir = 0;
%! apperture = 45;
%! n = 100;
%! t = 1:n;
%! azim = linspace(dir-apperture/2, dir+apperture/2, n);
%! azim = azimuth_range_positive(azim);
%!   myassert(all(azim <= 360))
%! ti = t;
%! azimi = azimuth_interp (t, azim, ti);
%! figure
%!   hold on
%!   plot(t, azim, '.-r')
%!   plot(ti, azimi, 'x-b')
%!   legend('Original', 'Interpolated')
%! max(abs(azimi - azim))
%! myassert(azimi, azim, 10*eps)

