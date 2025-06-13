function [y2, p] = azimuth_nanpolyfitval (x, y, n, varargin)
    y = unwrapd(y);
    [y2, p] = nanpolyfitval(x, y, n, varargin{:});
    y2 = azimuth_range(y2);
end
