function [alpha_db, alpha, beta, beta_sq] = get_gps_polar_ellipticity (...
freq_name, block_name)
    all = get_polar_ellipticity_all ();
    idx = strcmp(all.freq_name, freq_name) ...
        & arrayfun(@(i) any(strcmp(all.block_name{i}, block_name), 2), ...
            (1:length(all.block_name))');
    %myassert(sum(idx) == 1);
    if (sum(idx) ~= 1)
        error('snr:get_gps_polar_ellipticity:badComb', ...
            'Unknown combination of frequency "%s", block "%s".',...
            freq_name, block_name);
    end
    alpha_db = all.alpha_db(idx);
    [beta, alpha] = convert_polar_ellipticity_alphadb2beta (alpha_db);
    beta_sq = beta.^2;
end

function all = get_polar_ellipticity_all ()
    % <http://www.gps.gov/technical/icwg/IS-GPS-200G.pdf>, sec. 3.3.1.9
    % Frequency Block alpha_dB
    % L1 II/IIA 1.2
    % L1 IIR/IIR-M/IIF 1.8
    % L2 II/IIA 3.2
    % L2 IIR/IIR-M/IIF 2.2
    % L5 IIF 2.4
    all.freq_name = {...
        'L1'
        'L1'
        'L2'
        'L2'
        'L5'
    };
    all.block_name = {...
        {'II', 'IIA'}, ...
        {'IIR', 'IIR-M', 'IIF', 'III'}, ...
        {'II', 'IIA'}, ...
        {'IIR', 'IIR-M', 'IIF','III'}, ...
        {'IIF','III'}
    };
    all.alpha_db = [...
        1.2 
        1.8 
        3.2 
        2.2 
        2.4 
    ];
end

