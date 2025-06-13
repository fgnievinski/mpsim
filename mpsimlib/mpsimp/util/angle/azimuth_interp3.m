function Ai = azimuth_interp3 (a, A, ai, method)
    if (nargin < 4),  method = [];  end
    
    % (azimuth is the angle w.r.t. positive y-axis, NOT positive x-axis.)
    y = cos(pi/180*A);  x = sin(pi/180*A);

    xi = azimuth_interp2(a, x, ai, method);
    yi = azimuth_interp2(a, y, ai, method);
    
    Ai = 180/pi * atan2(xi, yi);  % angle w.r.t. positive y-axis.
    if all(a >= 0),  Ai = azimuth_range_positive(Ai);  end
end
