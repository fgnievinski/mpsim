function alpha_db = convert_polar_ellipticity_beta2alphadb (beta)
    alpha = (1 + beta) / (1 - beta);
    %alpha_db = decibel_power(alpha);  % WRONG!
    alpha_db = decibel_amplitude(alpha);
end

