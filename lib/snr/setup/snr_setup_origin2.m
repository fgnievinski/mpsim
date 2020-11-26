function ref = snr_setup_origin2 (height_ant, height_off, ...
vec_arp_pivot, vec_apc_pivot, sat_epoch, velocity)
    if (nargin < 2) || isempty(height_off),  height_off = 0;  end
    if (nargin < 3) || isempty(vec_arp_pivot),  vec_arp_pivot = [0 0 0];  end
    if (nargin < 4) || isempty(vec_apc_pivot),  vec_apc_pivot = [0 0 0];  end
    if (nargin < 5) || isempty(sat_epoch),  sat_epoch = [];  end
    if (nargin < 6) || isempty(velocity),  velocity = [];  end

    num_ant = numel(height_ant);  % get_specular_point.m can input vectorial height_ant
    num_off = numel(height_off);  % snr_setup supports vectorial sett.ref.height_off.
    num_obs = numel(sat_epoch);
    if (num_ant < 1)
        error('snr:snr_setup_ref:badHeightAntenna', ...
            'Antenna height (sett.ref.height_ant) cannot be empty.');
    end
    if (num_off > 1)  % = ~isempty(height_off) && ~isscalar(height_off)
        if ~isvector(height_off)
            error('snr:snr_setup_ref:badHeightOffset', ...
                'Height offset (sett.ref.height_off) must be scalar or vectorial.');
        end
        if (num_off ~= num_obs)
            error('snr:snr_setup_ref:badHeightOffset', ...
                ['When height offset (sett.ref.height_off) is vectorial, '...
                 'is should have the same size as the satellite observations (setup.sat.elev).']);
        end
        if (num_ant > 1)
            error('snr:snr_setup_ref:badHeightOffset', ...
                ['When height offset (sett.ref.height_off) is vectorial, '...
                 'antenna height (sett.ref.height_ant) must be scalar.']);
        end
        if ~isempty(velocity)
            error('snr:snr_setup_ref:badHeightOffset', ...
                ['When height offset (sett.ref.height_off) is vectorial, '...
                 'vertical velocity (sett.ref.velocity) must be empty.']);
        end
        velocity = gradient(height_off, sat_epoch);
    elseif ~isempty(velocity)
        if ~isscalar(velocity)
            error('snr:snr_setup_ref:badVelocity', ...
                'Input vertical velocity (sett.ref.velocity) must be scalar.');
        end
        if ~all(sat_epoch == 0)
            height_off = velocity .* sat_epoch;
            num_off = num_obs;
        end
    end
    
    ref = struct();
    ref.pos_origin = [0 0 0];
    ref.dir_up = [0 0 1];
    ref.num_heights = max(num_off, num_ant);
    
    height_ant = colvec(height_ant);
    height_off = colvec(height_off);
    temp = height_ant + height_off;
    %temp = height_ant - height_off;
    ref.pos_pivot = add_all(ref.pos_origin, times_all(temp, ref.dir_up));
    ref.pos_arp   = add_all(ref.pos_pivot, vec_arp_pivot);
    ref.pos_apc   = add_all(ref.pos_pivot, vec_apc_pivot);
    % synonym:
    %ref.pos_ant = ref.pos_arp;  % WRONG!
    ref.pos_ant = ref.pos_apc;
    %height_offset  % DEBUG
    %ref.height = ref.pos_ant(:,3);  % WRONG! need sfc.pos_sfc0.
    
    ref.height_ant = height_ant;
    ref.height_off = height_off;
    ref.velocity = velocity;
end

