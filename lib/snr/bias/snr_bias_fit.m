function [coeff_direct, coeff_interf, snr_simul_trend, snr_meas_detrended, pre] = snr_bias_fit (...
snr_meas, indep, graz, ...
snr_simul_trend, snr_simul_trend2, snr_simul, pre, ...
idx_lim_trend, idx_lim_fringe, ...
degree_trend, degree_fringe_aux, ...
inv_ratio_trend, inv_ratio_fringe, ...
trend_only, refine_peak, ...
height_domain, wavelength, ...
prefit_trend, postfit_trend, ...
plotit, num_obs_min, do_chirp, heightbias2phaseslope)
    if (nargin < 07),  pre = struct();  end
    if (nargin < 08),  idx_lim_trend = [];  end
    if (nargin < 09),  idx_lim_fringe = [];  end
    if (nargin < 10),  degree_trend = [];  end
    if (nargin < 11),  degree_fringe_aux = [];  end
    if (nargin < 12),  inv_ratio_trend = [];  end        
    if (nargin < 13),  inv_ratio_fringe = [];  end        
    if (nargin < 14),  trend_only = [];  end
    if (nargin < 15),  refine_peak = [];  end
    if (nargin < 16),  height_domain = [];  end
    if (nargin < 17),  wavelength = [];  end
    if (nargin < 18),  prefit_trend = [];  end
    if (nargin < 19),  postfit_trend = [];  end
    if (nargin < 20),  plotit = false;  end
    if (nargin < 21),  num_obs_min = [];  end
    if (nargin < 22),  do_chirp = [];  end
    if (nargin < 23),  heightbias2phaseslope = [];  end
    if isempty(plotit),  plotit = false;  end
    %plotit = true;  % DEBUG

    snr_meas_trend = setel(snr_meas, idx_lim_trend, NaN);
    [coeff_direct, snr_ratio_trend, ~, inv_ratio_trend] = snr_bias_fit_trend (...
        snr_meas_trend, indep, ...
        snr_simul_trend, snr_simul_trend2, ...
        degree_trend, prefit_trend, postfit_trend, plotit, inv_ratio_trend);

    if inv_ratio_trend,  snr_ratio_trend = 1./snr_ratio_trend;  end
    snr_simul_trend = snr_simul_trend ./ snr_ratio_trend;
    snr_simul       = snr_simul       ./ snr_ratio_trend;
      if plotit,  figure, hold on, plot(snr_meas, 'b'), plot(setel(snr_simul_trend, isnan(snr_meas), NaN), 'r'), plot(setel(snr_simul, isnan(snr_meas), NaN), 'g');  end

    if ~isfield(pre, 'fringe'),  pre.fringe = [];  end
    snr_meas_fringe = setel(snr_meas, idx_lim_fringe, NaN);
    [coeff_interf, snr_meas_detrended, ~, pre.fringe] = snr_bias_fit_fringe (...
        snr_meas_fringe, graz, ...
        snr_simul_trend, snr_simul, ...
        pre.fringe, trend_only, num_obs_min, ...
        degree_fringe_aux, ...
        refine_peak, height_domain, wavelength, ...
        plotit, inv_ratio_fringe);

    coeff_interf = snr_bias_fit_fringe_chirp (...
        coeff_interf, do_chirp, idx_lim_fringe, ...
        snr_meas, indep, graz, ...
        snr_simul_trend, snr_simul, ...
        pre, trend_only, num_obs_min, ...
        degree_fringe_aux, ...
        refine_peak, height_domain, wavelength, ...
        plotit, inv_ratio_fringe);
end

%%
function coeff_interf = snr_bias_fit_fringe_chirp (...
coeff_interf, chirp_chunks, idx_lim_fringe, ...
snr_meas, indep, graz, ...
snr_simul_trend, snr_simul, ...
pre, trend_only, num_obs_min, ...
degree_fringe_aux, ...
refine_peak, height_domain, wavelength, ...
plotit, inv_ratio_fringe)

    if isempty(chirp_chunks) || (chirp_chunks < 2)
        coeff_interf.chirp = 0;
        coeff_interf.indep_mid = 0;
        return
    end        
    
    if (chirp_chunks > 2)
        coeff_interf = snr_bias_fit_fringe_chirp_multi (...
            coeff_interf, chirp_chunks, idx_lim_fringe, ...
            snr_meas, indep, graz, ...
            snr_simul_trend, snr_simul, ...
            pre, trend_only, num_obs_min, ...
            degree_fringe_aux, ...
            refine_peak, height_domain, wavelength, ...
            plotit, inv_ratio_fringe);
        return
    end

    force_pre = true;
    do_snr_bias_fit_fringe = @(snr_meas_which, pre) snr_bias_fit_fringe (...
        snr_meas_which, graz, ...
        snr_simul_trend, snr_simul, ...
        pre.fringe, trend_only, num_obs_min, ...
        degree_fringe_aux, ...
        refine_peak, height_domain, wavelength, ...
        plotit, inv_ratio_fringe, force_pre);

    indep_fringe = setel(indep, idx_lim_fringe, NaN);
    indep_fringe_mid = nanmedian(indep_fringe);
    indep_fringe_lo = setel(indep_fringe, indep_fringe > indep_fringe_mid, NaN);
    indep_fringe_hi = setel(indep_fringe, indep_fringe < indep_fringe_mid, NaN);
    snr_meas_fringe_lo = setel(snr_meas, isnan(indep_fringe_lo), NaN);
    snr_meas_fringe_hi = setel(snr_meas, isnan(indep_fringe_hi), NaN);
    coeff_interf_lo = do_snr_bias_fit_fringe (snr_meas_fringe_lo, pre);
    coeff_interf_hi = do_snr_bias_fit_fringe (snr_meas_fringe_hi, pre);
    
    height_hi = coeff_interf_hi.height;
    height_lo = coeff_interf_lo.height;
    height_change = height_hi - height_lo;
    height_avg = (height_hi + height_lo)/2;
    %if ~inv_ratio_fringe,  height_change = -height_change;  end
    indep_fringe_lo_mid = nanmedian(indep_fringe_lo);
    indep_fringe_hi_mid = nanmedian(indep_fringe_hi);
    indep_change = indep_fringe_hi_mid - indep_fringe_lo_mid;
    height_slope = height_change / indep_change;
    chirp_bias = 0.5 * height_slope;
    %vertwavenum_change = indep_change * heightbias2phaseslope;
    %chirp_bias = 0.5 * height_slope * heightbias2phaseslope^2;
    %chirp_bias = 0;  % DEBUG
    coeff_interf.chirp = chirp_bias;
    coeff_interf.indep_mid = indep_fringe_mid;
    coeff_interf.height = height_avg;
    %coeff_interf.phase = angle_mean([coeff_interf_hi.phase coeff_interf.phase coeff_interf_lo.phase]);  
    %coeff_interf.phase = angle_mean([coeff_interf_hi.phase coeff_interf_lo.phase]);  
    
    %display(coeff_direct)  % DEBUG
    %display(coeff_interf)  % DEBUG
end

%%
function coeff_interf = snr_bias_fit_fringe_chirp_multiple (...
coeff_interf, chirp_chunks, idx_lim_fringe, ...
snr_meas, indep, graz, ...
snr_simul_trend, snr_simul, ...
pre, trend_only, num_obs_min, ...
degree_fringe_aux, ...
refine_peak, height_domain, wavelength, ...
plotit, inv_ratio_fringe)

    force_pre = true;
    do_snr_bias_fit_fringe = @(snr_meas_which, pre) snr_bias_fit_fringe (...
        snr_meas_which, graz, ...
        snr_simul_trend, snr_simul, ...
        pre.fringe, trend_only, num_obs_min, ...
        degree_fringe_aux, ...
        refine_peak, height_domain, wavelength, ...
        plotit, inv_ratio_fringe, force_pre);

    indep_fringe = setel(indep, idx_lim_fringe, NaN);    
    tmp = prctile(indep_fringe, 100/chirp_chunks);

    for i=1:chirp_chunks
    end
    indep_fringe_mid = nanmedian(indep_fringe);
    indep_fringe_lo = setel(indep_fringe, indep_fringe > indep_fringe_mid, NaN);
    indep_fringe_hi = setel(indep_fringe, indep_fringe < indep_fringe_mid, NaN);
    snr_meas_fringe_lo = setel(snr_meas, isnan(indep_fringe_lo), NaN);
    snr_meas_fringe_hi = setel(snr_meas, isnan(indep_fringe_hi), NaN);
    coeff_interf_lo = do_snr_bias_fit_fringe (snr_meas_fringe_lo, pre);
    coeff_interf_hi = do_snr_bias_fit_fringe (snr_meas_fringe_hi, pre);
    
    height_hi = coeff_interf_hi.height;
    height_lo = coeff_interf_lo.height;
    height_change = height_hi - height_lo;
    height_avg = (height_hi + height_lo)/2;
    %if ~inv_ratio_fringe,  height_change = -height_change;  end
    indep_fringe_lo_mid = nanmedian(indep_fringe_lo);
    indep_fringe_hi_mid = nanmedian(indep_fringe_hi);
    indep_change = indep_fringe_hi_mid - indep_fringe_lo_mid;
    height_slope = height_change / indep_change;
    chirp_bias = 0.5 * height_slope;
    %vertwavenum_change = indep_change * heightbias2phaseslope;
    %chirp_bias = 0.5 * height_slope * heightbias2phaseslope^2;
    %chirp_bias = 0;  % DEBUG
    coeff_interf.chirp = chirp_bias;
    coeff_interf.indep_mid = indep_fringe_mid;
    coeff_interf.height = height_avg;
    %coeff_interf.phase = angle_mean([coeff_interf_hi.phase coeff_interf.phase coeff_interf_lo.phase]);  
    %coeff_interf.phase = angle_mean([coeff_interf_hi.phase coeff_interf_lo.phase]);  
    
    %display(coeff_direct)  % DEBUG
    %display(coeff_interf)  % DEBUG
end
