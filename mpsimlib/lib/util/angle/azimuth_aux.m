function azim = azimuth_aux (varargin)
    if (nargin == 1)
        xy = varargin{1};
        x = xy(:,1);
        y = xy(:,2);
    else
        [x,y] = deal(varargin{:});
    end
    %azim = 180/pi * atan2(y, x);  % angle w.r.t. positive x-axis.
    azim = 180/pi * atan2(x, y);  % angle w.r.t. positive y-axis.
end
