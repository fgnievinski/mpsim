function [coeff, snr_meas_detrended, snr_meas_detrended_fit, pre] = snr_bias_fit_fringe (...
snr_meas, elev, ...
snr_simul_trend, snr_simul, ...
pre, trend_only, num_obs_min, ...
degree, ...
refine_peak, height_domain, wavelength, ...
plotit, inv_ratio, force_pre)
    if (nargin < 05),  pre = [];  end
    if (nargin < 06) || isempty(trend_only),  trend_only = false;  end
    if (nargin < 07) || isempty(num_obs_min),  num_obs_min = 10;  end
    if (nargin < 08),  degree = [];  end
    if (nargin < 09),  refine_peak = [];  end
    if (nargin < 10),  height_domain = [];  end
    if (nargin < 11),  wavelength = [];  end
    if (nargin < 12) || isempty(plotit),  plotit = false;  end        
    if (nargin < 13) || isempty(inv_ratio),  inv_ratio = false;  end        
    if (nargin < 14) || isempty(force_pre),  force_pre = false;  end        
    %plotit = true;  % DEBUG
    
    % CRITICAL:
    idx_nan = isnan(snr_meas) | isnan(elev);
    snr_simul = setel(snr_simul, idx_nan, NaN);
    snr_simul_trend = setel(snr_simul_trend, idx_nan, NaN);
    
    snr_meas_detrended  = snr_meas  - snr_simul_trend;
    snr_simul_detrended = snr_simul - snr_simul_trend;
      if plotit,  figure, hold on, plot(snr_meas_detrended, 'b'), plot(snr_simul_detrended, 'g');  end
    
    sufficient_obs = ( sum(~isnan(snr_meas)) >= num_obs_min );
    %if ~sufficient_obs,  trend_only = true;  end  % WRONG!
    if ~sufficient_obs
        coeff = struct('height',NaN, 'power',NaN, 'phase',NaN);
        snr_meas_detrended_fit = NaN(size(elev));
        warning('snr:snr_bias_fit_fringe:fewObs', ...
            'Insufficient number of observations for fringe bias fitting.')
        return;
    end
    if trend_only
        coeff = struct('height',[], 'power',[], 'phase',[]);
        snr_meas_detrended_fit = snr_meas_detrended;
        return;
    end
    
    if isempty(pre)
        pre = struct('elev',elev, 'idx_nan',idx_nan, 'J',[], 'peak_simul',[]);
    elseif ~isequaln(pre.elev, elev)
        pre.elev = elev;
        pre.idx_nan = idx_nan;
        pre.J = [];
        pre.peak_simul = [];
        warning('snr:snr_bias_fit_fringe:badPre', ...
            'Inapplicable pre-processed results (J); ignoring it.')
    elseif ~isequaln(pre.idx_nan, idx_nan) && ~force_pre
        % (reuse only the Jacobian matrix.)
        pre.idx_nan = idx_nan;
        pre.peak_simul = [];
        %warning('snr:snr_bias_fit_fringe:badPre', ...
        %    'Inapplicable pre-processed results (peak_simul); ignoring it.')
    end

    [peak_meas, snr_meas_detrended_fit, snr_meas_detrended, pre.J] = snr_bias_fit_sinusoid (...
        snr_meas_detrended, elev, degree, refine_peak, ...
        height_domain, wavelength, pre.J, plotit);
      if plotit,  figure, hold on, plot(snr_meas_detrended, 'b'), plot(snr_meas_detrended_fit, 'r');  end

    if isfieldempty(pre, 'peak_simul')
        [pre.peak_simul, snr_simul_detrended_fit] = snr_bias_fit_sinusoid (...
            snr_simul_detrended, elev, degree, refine_peak, ...
            height_domain, wavelength, pre.J, plotit);
        %figure, plot(elev, [snr_simul_detrended snr_simul_detrended_fit])
        snr_simul_detrended_fit = setel(snr_simul_detrended_fit, idx_nan, NaN);
        snr_simul_detrended_err = snr_simul_detrended_fit - snr_simul_detrended;
        tmp = nanrmse(snr_simul_detrended_err) / nanrmse(snr_simul_detrended);
        if (tmp > 0.75)
            warning('matlab:snr:inv:prelimFitSimulPoor', ...
                ['Poor fit to simulations in preliminary fit; aliasing likely;\n'...
                 'please check nominal reflector heigth vis-a-vis trial height domain.'])
        end
          if plotit,  figure, hold on, plot(snr_simul_detrended, 'b'), plot(snr_simul_detrended_fit, 'r');  end
          if plotit,  doplotit (elev, snr_meas_detrended, snr_meas_detrended_fit, snr_simul_detrended, snr_simul_detrended_fit);  end
    end
    
    peak_num = pre.peak_simul;
    peak_den = peak_meas;
    % (this convention must be consistent with that in snr_fwd_bias.m)
    %inv_ratio  % DEBUG
    if inv_ratio,  [peak_den, peak_num] = deal(peak_num, peak_den);  end
    coeff = struct();
    coeff.power  = snr_bias_fit_power(peak_num.power/peak_den.power, 0, 0);
    coeff.phase  = angle_diff(peak_num.phase, peak_den.phase);
    coeff.height = peak_num.height - peak_den.height;
    %coeff.height = 0;  coeff.power = 1;  coeff.phase = 180;  % DEBUG    
end

%%
function doplotit (elev, snr_meas_detrended, snr_meas_detrended_fit, snr_simul_detrended, snr_simul_detrended_fit)
    sine = sind(elev);
    %%
    k(1) = range(snr_meas_detrended_fit)/2;
    k(2) = range(snr_simul_detrended_fit)/2;
    k(3) = 10.^min(floor(log10(k(1:2))));
    figure
      h = [];
      ha = tight_subplot(2, 1, 0.002, [0.1 0.025], [0.05 0.05]);
      %ha(2)=ha(1);  % DEBUG
      hold(ha(1), 'on')
      hold(ha(2), 'on')
      h(1) = plot(ha(1), sine, snr_meas_detrended./k(3), '.-b');
      h(3) = plot(ha(2), sine, snr_simul_detrended./k(3), '.-b');
      h(2) = plot(ha(1), sine, snr_meas_detrended_fit./k(3), '-r');
      h(4) = plot(ha(2), sine, snr_simul_detrended_fit./k(3), '-r');
      set(h([1 3]), 'LineWidth',1)
      set(h([2 4]), 'LineWidth',3)
      set(ha(2), 'YAxisLocation','right')
      elev_lim = [5 ceil(max(elev(~isnan(snr_meas_detrended))))];
      elev_lim = [5 30];
      elev_lim = [5 60];
      k(4) = min(abs(ylim(ha(1))));
      k(5) = min(abs(ylim(ha(2))));
      k(6) = max(k(4), k(5));
      for i=1:2
        xlim(ha(i), sind(elev_lim))
        ylim(ha(i), k(6)*[-1 +1]*1/2)
        axes(ha(i)),  set_xtick_label_asind2()
        grid(ha(i), 'on')
        xlim(sind(elev_lim))
        set(ha(i), 'XTickLabel',[])
        %set(ha(i), 'YTickLabel',[])
        set(ha(i), 'YTickLabelMode','auto')
        %ylabel(ha(i), sprintf('\\times 10^{%.0f}', log10(k(3))))
        %%ylabel(ha(i), sprintf('\\times 10^{%.1f}', log10(k(i))))
      end
      %set(ha([1 3]), 'YAxisLocation','right')
      axes(ha(1)) %#ok<MAXES>
        hline(0, '-k')
      axes(ha(end)) %#ok<MAXES>
        hline(0, '-k')
        set(gca, 'XTick',sind(5:5:30))
        set_xtick_label_asind('%.0f')
        %set_xtick_label_asind2()
        xlim(sind(elev_lim))
        xlabel('Elevation angle (degrees)')
      ht(1) = annotation('textbox',...
        [0.120535714285714 0.562492063492063 0.183035714285714 0.0595238095238095],...
        'String',{'Measurement'});
      ht(2) = annotation('textbox',...
        [0.120535714285714 0.433523809523807 0.150297619047619 0.0595238095238095],...
        ...%[0.120535714285714 0.118047619047617 0.150297619047619 0.0595238095238095],...
        'String',{'Simulation'});
      set(ht, ...
        'FontWeight','bold',...
        'FontName','Arial',...
        'FontSize',12,...
        'FitBoxToText','off',...
        'EdgeColor','none');
end
