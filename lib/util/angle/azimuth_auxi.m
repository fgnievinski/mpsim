function varargout = azimuth_auxi (azim, magn)
    % (azim is the angle w.r.t. positive y-axis, NOT positive x-axis.)
    x = sind(azim);
    y = cosd(azim);
    if (nargin > 1) && ~isempty(magn)
        x = x .* magn;
        y = y .* magn;
    end
    if (nargout <= 1)
        varargout = {[x, y]};
    else
        varargout = {x, y};
    end
end
