function quad = azimuth_quadrant (azim, dir)
    if (nargin < 2) || isempty(dir),  dir = 'ccw';  end
    azim = azimuth_range_positive (azim);
    quad = NaN(size(azim));
    switch dir
    case {'cw', 'clockwise'}
        idx = (  0 <= azim & azim <  90);  quad(idx) = 1;
        idx = ( 90 <= azim & azim < 180);  quad(idx) = 2;
        idx = (180 <= azim & azim < 270);  quad(idx) = 3;
        idx = (270 <= azim & azim < 360);  quad(idx) = 4;
    case {'ccw', 'counter-clockwise'}
        idx = (  0 <= azim & azim <  90);  quad(idx) = 1;
        idx = ( 90 <= azim & azim < 180);  quad(idx) = 4;
        idx = (180 <= azim & azim < 270);  quad(idx) = 3;
        idx = (270 <= azim & azim < 360);  quad(idx) = 2;
    otherwise
        error('MATLAB:azimuth_quadrant:unkDir', 'Unknown direction "%s".', dir);
    end
    idx = ( isnan(quad(:)) & ~isnan(azim(:)) );
    assert(~any(idx))  % we didn't miss any.
end

%!test
%! azim = [...
%!   -1, 0, +1
%!   89, 90, 91
%!   179, 180, 181
%!   269, 270, 271
%!   359, 360, 361
%! ];
%! quad = [...
%!   2 1 1
%!   1 4 4
%!   4 3 3
%!   3 2 2
%!   2 1 1
%! ];
%! 
%! quad2 = azimuth_quadrant (azim);
%! %[azim, NaN(5,1), quad, NaN(5,1), quad2, NaN(5,1), quad2-quad]  % DEBUG
%! myassert(quad2, quad)

%!test
%! azim = [...
%!   -1, 0, +1
%!   89, 90, 91
%!   179, 180, 181
%!   269, 270, 271
%!   359, 360, 361
%! ];
%! quad = [...
%!   4 1 1
%!   1 2 2
%!   2 3 3
%!   3 4 4
%!   4 1 1
%! ];
%! 
%! quad2 = azimuth_quadrant (azim, 'clockwise');
%! %[azim, NaN(5,1), quad, NaN(5,1), quad2, NaN(5,1), quad2-quad]  % DEBUG
%! myassert(quad2, quad)
