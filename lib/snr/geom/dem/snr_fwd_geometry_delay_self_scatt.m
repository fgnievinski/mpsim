function [dist, dir] = snr_fwd_geometry_delay_self_scatt (pos_sfc_horiz, sat_dir, pos_ant, sfc, sfc_height) %#ok<INUSL>
    if (nargin < 5),  sfc_height = snr_fwd_geometry_height_self (pos_sfc_horiz, sfc);  end
    pos_sfc = [pos_sfc_horiz, sfc_height];
    %delta = minus_all(pos_sfc, pos_ant);  % from antenna to surface;  WRONG!
    delta = minus_all(pos_ant, pos_sfc);  % from surface to antenna
    dist = norm_all(delta);
    if (nargout < 2),  return;  end
    dir = divide_all(delta, dist);
end

