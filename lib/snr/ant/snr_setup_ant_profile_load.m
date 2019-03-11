function answer = snr_setup_ant_profile_load (filepath, comp_type)
    gain_delta_default = 0;
    data = load(filepath, '-ascii');

    %% extended format?
    [m,n] = size(data);
    if (n == 2),  data = horzcat(data(:,1), zeros(m,1), data(:,2));  end
      
    %% extract header line containing the delta:
    assert(isnan(data(1,1)))
    delta = data(1,3);
    data(1,:) = [];
    
    %% map from the original boresight angle to elevation and azimuth angles:
    [ang, azi, val] = deal2(data);
    [angp, azim] = angle_boresight_positive (ang, azi);
    elev = 90 - angp;
    clear ang  % prevent misuse.

    %% get delta:
    if isnan(delta)
        switch comp_type
        case 'phase',  delta = 0;
        case 'gain'
            delta = gain_delta_default;
            msg = sprintf('Unknown antenna gain delta value; assuming %.1f dB.\n', delta);
            if is_octave()
                warning('snr:ant:Profile:noDelta', [msg ...
                     'To disable this warning message, enter:' ...
                     'warning(''off'',''snr:ant:Profile:noDelta'')']);
            else
                warning('snr:ant:Profile:noDelta', [msg, ...
                     '(To disable this warning message, ' ...
                     '<a href="matlab: warning(''off'',''snr:ant:Profile:noDelta'')">'...
                     'click here</a>.']);
            end
        end
    end

    %% pack data struct:    
    myassert(~any(isnan(elev)))
    myassert(~any(isnan(azim)))

    answer = struct(...
        'ang',angp, ...
        'elev',elev, ...
        'azim',azim, ...
        'delta',delta, ...
        'offset',delta ...  % legacy interface
    );
    answer.original = val - delta;
    
    switch lower(comp_type)
    case 'gain'
        answer.original_label = 'Gain';
        answer.original_units = 'dB';
        answer.gain_db = answer.original;
        answer.power_gain_lin = decibel_power_inv(answer.gain_db);
        answer.amplitude_gain_lin = decibel_amplitude_inv(answer.gain_db);
        answer.final = answer.amplitude_gain_lin;
        answer.original2final = @decibel_amplitude_inv;
        answer.final2original = @decibel_amplitude;
        answer.final_label = 'Linear gain';
        answer.final_units = 'V/V';
    case 'phase'
        answer.original_label = 'Phase';
        answer.original_units = 'degrees';
        answer.final_label = 'Phase';
        answer.final_units = 'degrees';
        answer.final = answer.original;
        answer.original2final = @itself;
        answer.final2original = @itself;
    otherwise
        error('snr:ant:Profile:badCompType', ...
            'Unknown component type "%s"; should be "gain" or "phase".', ...
            comp_type);
    end    
end

