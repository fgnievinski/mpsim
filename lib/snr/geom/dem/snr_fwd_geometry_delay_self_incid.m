function [dist, dir] = snr_fwd_geometry_delay_self_incid (pos_sfc_horiz, dir_sat, pos_ant, sfc, sfc_height, method)
    if (nargin < 5),  sfc_height = snr_fwd_geometry_height_self (pos_sfc_horiz, sfc);  end
    if (nargin < 6) || isempty(method),  method = 'infinity';  end
    %method = 'finite';  % DEBUG
    pos_sfc = [pos_sfc_horiz, sfc_height];
    if strcmp(method, 'infinity')
        temp = minus_all(pos_sfc, pos_ant);
        %answer = dot_all(temp, dir_sat);  % WRONG!
        dist = dot_all(temp, -dir_sat);
    else
        D = 1e10;
        pos_sat = add_all(pos_ant, D .* dir_sat);
        dist = norm_all(minus_all(pos_sat, pos_sfc)) ...
             - norm_all(minus_all(pos_sat, pos_ant));
    end
    dir = -dir_sat;
end

%TODO: test delay_incid_method.

