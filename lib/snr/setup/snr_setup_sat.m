function sat = snr_setup_sat (sett_sat)
    if (nargin < 1) || isempty(sett_sat) || isequal(sett_sat, struct())
        sat = struct();
        return;
    end
    %if all(isfield(sett_sat, {'azim', 'elev'}))
    if isfield(sett_sat, 'elev')
        if ~isfield(sett_sat, 'azim'),   sett_sat.azim  = [];  end
        if ~isfield(sett_sat, 'epoch'),  sett_sat.epoch = [];  end
        sat = snr_setup_sat_simple (...
            sett_sat.epoch, sett_sat.azim, sett_sat.elev);
    elseif isfield(sett_sat, 'elev_lim')
        if ~isfield(sett_sat, 'num_obs'),   sett_sat.num_obs  = [];  end
        if ~isfield(sett_sat, 'azim_lim'),   sett_sat.azim_lim  = [];  end
        if ~isfield(sett_sat, 'epoch_lim'),  sett_sat.epoch_lim = [];  end
        if ~isfield(sett_sat, 'regular_in_sine'),  sett_sat.regular_in_sine = [];  end
        sat = snr_setup_sat_default (sett_sat.num_obs, ...
            sett_sat.epoch_lim, sett_sat.azim_lim, sett_sat.elev_lim, ...
            sett_sat.regular_in_sine);
    else
        error('snr:snr_setup_sat:badInput', 'Bad input.');
    end
end

