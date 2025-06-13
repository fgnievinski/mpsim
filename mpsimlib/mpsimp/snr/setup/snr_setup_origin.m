function ref = snr_setup_origin (varargin)
    if (nargin == 1) && ~isstruct(varargin{1})
    %if (nargin == 1) && isscalar(varargin{1})  % WRONG!
        % legacy interface:
        height_ant = varargin{1};
        ref = snr_setup_origin2 (height_ant);
        return;
    end
    ref = snr_setup_origin_aux (varargin{:});
end

function ref = snr_setup_origin_aux (sett_ref, vec_apc_arp_upright, ant_rot, sat_epoch)
    if (nargin < 2),  vec_apc_arp_upright = [];  end
    if (nargin < 3),  ant_rot = [];  end
    if (nargin < 4),  sat_epoch = [];  end
    ref1 = snr_setup_origin1 (...
        sett_ref.dist_arp_pivot, sett_ref.ignore_vec_apc_arp, ...
        vec_apc_arp_upright, ant_rot);
    ref2 = snr_setup_origin2 (...
        sett_ref.height_ant, sett_ref.height_off, ...
        ref1.vec_arp_pivot, ref1.vec_apc_pivot, ...
        sat_epoch, sett_ref.velocity);
    ref = structmerge(ref1, ref2);
end
