function [delay, more] = snr_po_delay (pos_sfc, pos_ant, ...
dir_sat_direct, dist_sat_direct, dist_scatt)
    vec_scatt = [];
    if (nargin < 5) || isempty(dist_scatt)
        vec_scatt = subtract_all(pos_ant, pos_sfc);
        dist_scatt = sqrt(dot_all(vec_scatt));
    end

    %% Receiver-satellite position difference vector:
    vec_sat_direct = dir_sat_direct .* dist_sat_direct;
    
    %% Surface-satellite vector:
    pos_sat = pos_ant + vec_sat_direct;
    %% Vector from surface to satellite:
    vec_sat = subtract_all(pos_sat, pos_sfc);  % = pos_sat - pos_sfc
    %% Surface-satellite distance:
    dist_sat = sqrt(dot_all(vec_sat));
    
    %% Propagation delay (w.r.t. direct path) [m]:
    delay = dist_scatt + dist_sat - dist_sat_direct;

    if (nargout < 2),  return;  end
    more = struct();
    more.delay = delay;
    more.dir_sat_direct = dir_sat_direct;
    more.dist_sat       = dist_sat;
    more.vec_sat        = vec_sat;
    if (nargin < 5)
        more.dist_scatt = dist_scatt;
        more.vec_scatt  = vec_scatt;
    end
end


