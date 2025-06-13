function [sat, idx, ind] = snr_setup_sat_simple (epoch, azim, elev)
    epoch = colvec(epoch);
    azim  = colvec(azim);
    elev  = colvec(elev);
    num_obs = numel(elev);
    %epoch_default = (1:num_obs)';
    %epoch_default = (0:num_obs-1)';
    %epoch_default = NaN(num_obs,1);
    epoch_default = zeros(num_obs,1);  % frozen in time.
    if isempty(epoch)
        epoch = epoch_default;
    else
        assert(numel(epoch) == num_obs)
    end
    if isempty(azim),  azim = 0;  end
    if isscalar(azim)
        azim = repmat(azim, [num_obs 1]);
    else
        assert(numel(azim) == num_obs)
    end

    % Temporal rates:
    if isempty(epoch)
        elev_rate = [];
        azim_rate = [];
        % avoid error 'MATLAB:gradient:InvalidInputs'.
    elseif isequaln(epoch, epoch_default) || is_uniform(epoch)
        elev_rate = NaN(num_obs,1);
        azim_rate = NaN(num_obs,1);
    else
        elev_rate = gradient(elev, epoch);
        azim_rate = gradient(azim, epoch);
    end
    
    if isempty(elev)
        % makes it possible to run snr_fwd:
        temp = zeros(0,1);
        epoch = temp;
        elev  = temp;
        azim  = temp;
        elev_rate = temp;
        azim_rate = temp;
    end
        
    % Keep original -- including NaNs -- for fastest retrieval:
    original = struct();
    original.epoch = epoch;
    original.elev  = elev;
    original.azim  = azim;
    original.elev_rate = elev_rate;
    original.azim_rate = azim_rate;

    % Discard NaNs:
    idx = isnan(original.epoch);
    if any(idx)
        %getel = @(f) f(~idx);
        getel = @(f) getelif_nonempty(f, idx);
        nonnan = structfun2(getel, original);
    else
        nonnan = original;
    end
    
    % Speed-up subsequent interpolation by pre-sorting data:
    if ~issorted(nonnan.epoch);
        ind = argsort(nonnan.epoch);
        %getel = @(f) f(ind);
        getel = @(f) getelif_nonempty(f, ind);
        sorted = structfun2(getel, nonnan);
    else
        sorted = nonnan;
    end
    
    % Now pack eveything:
    sat = original;  % need fields at the base struct.
    sat.original = original;
    sat.sorted = sorted;
    sat.get_direction = @get_direction_simple;
    
    % (don't set the limits because they'd make snr_resetup to reset pre 
    %  when using measurements)
    sat.epoch_lim = [];
    sat.azim_lim  = [];
    sat.elev_lim  = [];
end

%TODO: effect of tropospheric refraction on incident elevation angle.

%%
function varargout = get_direction_simple (setup)
    sat = setup.sat;
    dir = struct();
    if isequaln(sat.epoch, sat.original.epoch)
        dir.elev = sat.original.elev;
        dir.azim = sat.original.azim;
        dir.elev_rate = sat.original.elev_rate;
        dir.azim_rate = sat.original.azim_rate;
    else
        %keyboard  % DEBUG
        method = 'linear';  extrap = NaN;
        myinterp1 = @(y) interp1_fastest(sat.sorted.epoch, y, sat.epoch, method, extrap);
        dir.elev = myinterp1(sat.sorted.elev);
        %dir.azim = myinterp1(sat.sorted.azim);  % WRONG!
        dir.azim = azimuth_interp(...
            sat.sorted.epoch, sat.sorted.azim, sat.epoch, method, extrap);
        dir.elev_rate = myinterp1(sat.sorted.elev_rate);
        dir.azim_rate = myinterp1(sat.sorted.azim_rate);
    end
    switch nargout
    case 1
        varargout = {dir};
    case 2
        varargout = {dir.azim, dir.elev};
    case 4
        varargout = {dir.azim, dir.elev, dir.azim_rate, dir.elev_rate};
    end
end

