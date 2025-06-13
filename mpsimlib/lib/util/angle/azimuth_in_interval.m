function isin = azimuth_in_interval (azim, type, varargin)
    switch lower(type)
    case {'central','center','centre'}
        isin = azimuth_in_interval_central (azim, varargin{:});
    case 'clockwise'
        isin = azimuth_in_interval_clockwise (azim, varargin{:});
    otherwise
        error('matlab:azimuth_in_interval:badType', 'Unknonw type.')
    end
end

function isin = azimuth_in_interval_central (azim, center, halfwidth)
    assert(all(halfwidth >= 0))
    isin = (abs(azimuth_diff(azim, center)) <= halfwidth);
end

function isin = azimuth_in_interval_clockwise (azim, left, right)
    %isin = left <= azim & azim <= right;  % WRONG!
    %isin = azimuth_diff(azim, left)  >= 0 ...
         %& azimuth_diff(azim, right) <= 0;  WRONG!
    %isin = azimuth_range_positive(azimuth_diff(azim, left))  >= 0 ...
    %     & azimuth_range_positive(azimuth_diff(azim, right)) <= 0;  % WRONG!
    %center = azimuth_mean(left, right);  % WRONG!
    %center = azimuth_mean2(left, right);  % WRONG!
    %halfwidth = azimuth_diff(right, center, true);
    fullwidth = azimuth_diff(right, left, true);
    halfwidth = fullwidth / 2;
    center = left + halfwidth;    
    isin = azimuth_in_interval_central (azim, center, halfwidth);
end

%!test
%! temp = [...
%!       0 100  50   1
%!     100   0  50   0
%!     100 -10  110  1
%!     100 +10   90  0
%!       0 100 -100  0
%!     -10 100 -110  0
%!     +10 100  -90  0
%!     350 100    0  1
%!    -350 100  -90  0
%!    3*360  1    0  1
%! ];
%! left  = temp(:,1);
%! right = temp(:,2);
%! azim  = temp(:,3);
%! isin  = temp(:,4);
%! isinb = azimuth_in_interval (azim, 'clockwise', left, right);
%! [temp, isinb, isinb-isin]  % DEBUG
%! myassert(isinb, isin)
