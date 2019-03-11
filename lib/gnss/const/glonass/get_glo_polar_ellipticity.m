function [alpha_db, alpha, beta, beta_sq] = get_glo_polar_ellipticity (freq_name)
    all = get_polar_ellipticity_all ();
    idx = strcmp(all.freq_name, freq_name);
    if (sum(idx) ~= 1)
        error('snr:get_glo_polar_ellipticity:badComb', ...
            'Unknown frequency "%s".', freq_name);
    end
    alpha_inv = all.alpha_inv(idx);
    alpha = 1./alpha_inv;
    alpha_db = decibel_amplitude(alpha);
    %alpha_db = decibel_power(alpha);  % WRONG!
    beta = convert_polar_ellipticity_alphadb2beta (alpha_db);
    beta_sq = beta.^2;
end

function all = get_polar_ellipticity_all ()
    % From Edition 5.1 2008 ICD R1, R2 GLONASS, sec. 3.3.1.9
    % Frequency Block
    % R1 0.7
    % R2 0.7

    all.freq_name = {...
        'R1'
        'R2'
    };
    all.alpha_inv = [...
        0.7 
        0.7 
    ];
end

