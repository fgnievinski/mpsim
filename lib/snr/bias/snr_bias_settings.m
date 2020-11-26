function sett_bias = snr_bias_settings ()

    %% Evaluation of empirical biases in simulations:
    % (see snr_fwd_bias.m for details)
    sett_bias = struct();
    sett_bias.power_direct = [];  % [vector] Direct power bias polynomial coefficients (in decibels per polynomial basis raised to the i-th power)
    sett_bias.phase_direct = [];  % [vector] Direct phase bias polynomial coefficients; irrelevant for single-frequency simulations (in degrees per polynomial basis raised to the i-th power)
    sett_bias.power_interf = [];  % [vector] Interferometric power bias polynomial coefficients; zeroth-order constant, first-order linear change, second-order quadratic, etc. (in decibels per polynomial basis raised to the i-th power (zeroth, first, etc.))
    sett_bias.phase_interf = [];  % [vector] Interferometric phase bias polynomial coefficients; values are listed in ascending powers of the polynomial -- this is in contrast to polyval.m -- so phase_interf(1) is the zeroth-order or constant phase-shift (in degrees), phase_interf(2) is a first-order or linear phase variation (in degrees per polynomial basis), phase_interf(3) is a quadratic phase (in degrees per polynomial basis squared), etc.
    sett_bias.height = [];  % [scalar] Reflector height bias; in contrast to sett.ref.height_off, sett.bias.height does not redefine the antenna position (in meters)
    sett_bias.indep_type = [];  % [char] Independent coordinate type for evaluating polynomial bias coefficients ('zenith angle', 'elevation angle', 'sine of elevation angle', 'vertical wavenumber', 'sine of grazing angle', 'normal wavenumber')
    sett_bias.inv_ratio_trend = true;  % [scalar] Normally the nominal direct phasor is divided by the respective phasor biases; should we multiply instead? (logical/Boolean)
    sett_bias.inv_ratio_fringe = false;  % [scalar] Normally the nominal reflection phasor is divided by the respective phasor biases; should we multiply instead? (logical/Boolean)
    sett_bias.apply_direct_power_bias_only_at_end = true;  % [scalar] Apply direct power bias only after code tracking combination? This is inconsequential in case power losses are negligible (logical/Boolean)
    sett_bias.fixed = 5.5;  % [vector] Fixed multiplicative bias (polynomial coefficients)

    %% Fitting of biases against SNR measurements:
    % (see snr_fwd_bias_fit.m for details)
    sett_bias.fit = struct();
    sett_bias.fit.elev_lim_trend = [0 90];  % [vector] trend fitting (direct power bias) - satellite elevation angle limits; min, max (in degrees)
    sett_bias.fit.elev_lim_fringe = [0 35];  % [vector] fringe fitting (interferometric power and phase biases) - satellite elevation angle limits; min, max (in degrees)
    % Note: elev_lim_trend and elev_lim_fringe are useful for isolating a more representative portion of SNR observations. 
    sett_bias.fit.degree_trend = [];  % [scalar] trend fitting (direct power bias) - polynomial degree (NaN is disabled, 0 is a constant, 1 is a straight line, 2 is a parabola, etc.)
    sett_bias.fit.degree_fringe_aux = [];  % [scalar] fringe fitting - auxiliary polynomial degree (format as in degree_trend)
    % Note: degree_fringe_aux is useful when the fringe fitting would
    % benefit from a second localized detrending, when
    % bias.fit.elev_lim_fringe is narrower than bias.fit.elev_lim_trend;
    % see snr_bias_sinusoid_fit for details.
    sett_bias.fit.trend_only = [];  % [scalar] Fit only trend, skipping fringe fitting? (logical/Boolean)
    sett_bias.fit.refine_peak = 3;  % [scalar] Refine speactral peak? (integer, the number of iterations)
    % Note: refine_peak is useful when height_domain has coarse spacing; see mplsqfourier_refine.m for details.
    sett_bias.fit.height_domain = [];  % [vector or cell] Domain of heights to test in spectral analysis; see mplsqfourier_height.m and lsqfourier_period.m for format.
    sett_bias.fit.is_height_domain_relative = false;  % [scalar] Should antenna height (setup.ref.height_ant) be added to height domain? (logical/Boolean) Be careful not to include the antenna height in height_domain.
    sett_bias.fit.plotit = [];  % [scalar] Plot figures of internal fitting results (logical/Boolean)
    sett_bias.fit.num_obs_min = [];  % [scalar] Minimum number of observations required to attempt bias fitting (integer)
    sett_bias.fit.prefit_trend = [];
    sett_bias.fit.postfit_trend = [];
    
    %% Phase curvature (chirp) - EXPERIMENTAL
    sett_bias.fit.do_chirp = false;
    sett_bias.chirp = 0;
    sett_bias.indep_mid = 0;
end
