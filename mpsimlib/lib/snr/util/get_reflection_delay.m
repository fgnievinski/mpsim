function [delay, sine] = get_reflection_delay (height, elev, azim, slope, aspect)
    if (nargin < 4)
        sine = sind(elev);
        delay = 2 * height .* sine;
    else
        [~, ~, delay, sine] = snr_fwd_geometry_reflection_tilted_simple (...
            height, elev, azim, slope, aspect);
    end
end

