function sat = snr_setup_sat_default (num_obs, epoch_lim, azim_lim, elev_lim, regular_in_sine)
    if (nargin < 1) || isempty(num_obs),  num_obs = 250;  end
    if (nargin < 2) || isempty(epoch_lim),  epoch_lim = 0;  end
    if (nargin < 3) || isempty(azim_lim),  azim_lim = 0;  end
    if (nargin < 4) || isempty(elev_lim),  elev_lim = [5, 75];  end
    if (nargin < 5) || isempty(regular_in_sine),  regular_in_sine = true;  end
    
    if isscalar(epoch_lim),  epoch_lim = [epoch_lim, epoch_lim];  end
    if isscalar(azim_lim),   azim_lim  = [azim_lim, azim_lim];    end
    if isscalar(elev_lim),   elev_lim  = [elev_lim, elev_lim];    end
    
    epoch = linspace(epoch_lim(1), epoch_lim(2), num_obs)';
    azim  = linspace( azim_lim(1),  azim_lim(2), num_obs)';
    %elev = linspace( elev_lim(1),  elev_lim(2), num_obs)';
    if regular_in_sine
        elev = get_elev_regular_in_sine (num_obs, elev_lim(1), elev_lim(2), ...
            false, false, 'ascend');
    else
        elev = linspace(elev_lim(1), elev_lim(2), num_obs)';
    end
    
    sat = snr_setup_sat_simple (epoch, azim, elev);
end
