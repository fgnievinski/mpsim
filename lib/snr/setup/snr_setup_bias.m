function bias = snr_setup_bias (sett_bias, sat, opt) %#ok<INUSL>
    bias = sett_bias;
    [bias.indep_fnc, bias.height2phaserate, bias.indep_type] = snr_bias_indep_aux (...
        bias.indep_type, opt.wavelength);
    %bias.indep = snr_bias_indep (bias, sat);   % DANGEROUS
    % (commented out to avoid trouble with snr_resetup and snr_po1)
end
