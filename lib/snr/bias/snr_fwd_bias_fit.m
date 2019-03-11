function varargout = snr_fwd_bias_fit (snr_meas_db, setup, varargin)
%SNR_FWD_BIAS_FIT: Fits empirical biases for SNR measurements to match simulation.
% 
% SYNTAX:
%    setup = snr_fwd_bias_fit (snr_meas_db, setup);
%
% INPUT: none    
%    snr_meas_db: [vector] SNR measurements (in decibels)
%    setup: [structure] output of function snr_setup
%
% OUTPUT:
%    setup: [structure] setup with updated field "bias"
%    snr_simul_db_post: [vector] bias-corrected SNR simulation (in decibels)
%    snr_simul_trend_post: [vector] bias-corrected SNR trend simulation (in decibels)
%    snr_simul_detrended_post: [vector] bias-corrected SNR fringes simulation (in decibel difference)
%    snr_simul_detrended_post: [vector] SNR fringe measurements (in decibel difference)
%
% REMARKS:
% - This routine performs a polynomial regression to fit the trend,
%   followed by a spectral analysis to fit the oscillating fringe, 
%   based on a single sinusoid (amplitude, frequency, and phase-shift).
% - Input/output setup.bias is documented in snr_bias_settings.m

    if (nargin < 2) || isempty(setup),  setup = snr_setup();  end
    legacy = false;
    if isfieldempty(setup, 'sett')
        legacy = true;
        sett = setup;
        setup = snr_setup(sett);
    end
    if isfieldempty(setup, 'pre')
        setup.pre = getfield(snr_fwd(setup), 'pre'); %#ok<*GFLD>
    end
    [varargout{1:nargout}] = snr_fwd_bias_fit_aux (snr_meas_db, setup, varargin{:});
    if ~legacy || (nargout < 1),  return;  end
    varargout{1} = getfield(varargout{1}, 'sett');
end

%%
function [setup, snr_simul_db_post, snr_simul_trend_post, ...
snr_simul_detrended_post, snr_meas_detrended_post, pre] = snr_fwd_bias_fit_aux (...
snr_meas_db, setup, pre, return_fits)
    if (nargin < 3),  pre = struct();  end
    if (nargin < 4) || isempty(return_fits),  return_fits = true;  end
    %setup.bias.fit.plotit = true;  % DEBUG
    
    snr_meas = decibel_power_inv(snr_meas_db);
    [setup, pre] = snr_fwd_bias_fit_aux2 (setup, pre);
    
    [indep, graz, elev] = snr_bias_indep (setup.bias, setup.sat, setup.pre.geom);

    elev2idx = @(elev_lim) ~(elev_lim(1) <= elev & elev <= elev_lim(2));
    idx_lim_trend  = elev2idx(setup.bias.fit.elev_lim_trend);
    idx_lim_fringe = elev2idx(setup.bias.fit.elev_lim_fringe);
    
    if ~isfield(pre, 'bias'),  pre.bias = [];  end
    [coeff_direct, coeff_interf, ...
     snr_simul_trend_post, snr_meas_detrended_post, pre.bias] = snr_bias_fit (...
        snr_meas, indep, graz, ...
        pre.snr_simul_trend, pre.snr_simul_trend2, pre.snr_simul, pre.bias, ...
        idx_lim_trend, idx_lim_fringe, ...
        setup.bias.fit.degree_trend, setup.bias.fit.degree_fringe_aux, ...
        setup.bias.inv_ratio, setup.bias.fit.trend_only, setup.bias.fit.refine_peak, ...
        setup.bias.fit.height_domain, setup.opt.wavelength, ...
        setup.bias.fit.prefit_trend, setup.bias.fit.postfit_trend, ...
        setup.bias.fit.plotit, setup.bias.fit.num_obs_min);
    %TODO: offer height_domain relative to ant height.
    
    sett = setup.sett;
    sett.bias.height = coeff_interf.height;
    sett.bias.power_direct = coeff_direct;
    sett.bias.phase_interf = coeff_interf.phase;
    sett.bias.power_interf = coeff_interf.power;
    %sett.bias.power_interf = snr_bias_power_default();  % DEBUG
    setup = snr_resetup(sett, setup);

    if (nargout < 2),  return;  end
    if ~return_fits
        snr_simul_db_post = [];
        snr_simul_detrended_post = [];
    elseif any(structfun(@(x) isnan(x) || isempty(x), coeff_interf))
        siz = size(snr_meas_db);
        snr_simul_db_post = NaN(siz);
        snr_simul_detrended_post = NaN(siz);
    else
        temp = snr_fwd(setup);
        snr_simul_db_post = temp.snr_db;    
        snr_simul_post = decibel_power_inv(snr_simul_db_post);    
        snr_simul_detrended_post = snr_simul_post - snr_simul_trend_post;
    end      
      %figure, hold on, plot(snr_meas_db, '.k'), plot(snr_simul_db_post, '-r')
end

%%
function [setup, pre] = snr_fwd_bias_fit_aux2 (setup, pre)
    sett = setup.sett;
    %sett.sat = struct();  % WRONG! would make resetup to discard pre.
    %sett.sat.elev = elev;
    sett.bias.height = [];
    sett.bias.power_direct = [];
    sett.bias.power_interf = [];
    sett.bias.phase_interf = [];
    setup = snr_resetup(sett, setup);
    if ~isfield(setup.pre, 'geom'),  setup.pre.geom = [];  end

    if ~isfieldempty(pre, 'snr_simul_trend')  ...
    && ~isfieldempty(pre, 'snr_simul_trend2') ...
    && ~isfieldempty(pre, 'snr_simul')
        return;
    end
    
    setup1 = setup;  setup1.opt.special_fringes = 'disabled';
    setup2 = setup;  setup2.opt.disable_fringes = 'superior';
    setup3 = setup;  setup3.opt.disable_fringes = 'common';

    result1 = snr_fwd(setup1);
    setup2.pre = result1.pre;  
    setup3.pre = result1.pre;  
    result2 = snr_fwd(setup2);
    result3 = snr_fwd(setup3);
    
    pre.snr_simul_trend  = decibel_power_inv(result1.snr_db);
    pre.snr_simul_trend2 = decibel_power_inv(result2.snr_db);
    pre.snr_simul        = decibel_power_inv(result3.snr_db);
      %figure, hold on, plot(pre.snr_simul_trend, '.-k'), plot(pre.snr_simul, '-r', 'LineWidth',2), grid on, maximize()
end
