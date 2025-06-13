function answer = calc_diffraction2 (elev_sat, azim_sat, ant, opt2)
    [snr_db, answer] = calc_diffraction_series2 (elev_sat, azim_sat, ant, opt2, NaN); %#ok<ASGLU>
end
