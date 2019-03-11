% Convert from alpha_db, the major-to-minor-axis ratio of the 
% polarization ellipse, in decibels, to beta, the LHCP-to-RHCP 
% polarimetric ratio.
function [beta, alpha] = convert_polar_ellipticity_alphadb2beta (alpha_db)
    %alpha = decibel_power_inv(alpha_db);  % WRONG!
    alpha = decibel_amplitude_inv(alpha_db);
    %beta = (alpha - 1) ./ (1 + alpha);
    beta = (alpha - 1) ./ (alpha + 1);
end

