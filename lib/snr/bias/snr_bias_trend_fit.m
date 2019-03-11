function [coeff, snr_ratio_trend, snr_ratio_resid] = snr_bias_trend_fit (...
snr_meas, indep, ...
snr_simul_trend, snr_simul_trend2, ...
degree, prefit, postfit, plotit)
    if (nargin < 2),  indep = [];  end
    if (nargin < 3),  snr_simul_trend = 1;  end
    if (nargin < 4),  snr_simul_trend2 = 1;  end
    if (nargin < 5),  degree = [];  end
    if (nargin < 6),  prefit = [];  end
    if (nargin < 7) || isempty(postfit),  postfit = true;  end
    if (nargin < 8) || isempty(plotit),  plotit = false;  end
    
    if ~isscalar(snr_simul_trend),  snr_simul_trend(isnan(snr_meas)) = NaN;  end
    
    snr_ratio = snr_simul_trend ./ snr_meas;
    %snr_ratio = snr_meas ./ snr_simul_trend;  % WRONG!
      if plotit,  figure, hold on, plot(snr_meas, 'b'), plot(setel(snr_simul_trend, isnan(snr_meas), NaN), 'r');  end
      if plotit,  figure, plot(snr_ratio, '-k');  end

    [coeff, snr_ratio_trend, snr_ratio_resid] = snr_bias_trend_fit_aux (...
        snr_ratio, indep, degree, prefit, plotit);
      if plotit,  doplotit (indep, snr_meas, snr_simul_trend, snr_ratio, snr_ratio_trend, snr_ratio_resid);  end

    %postfit = false;  % DEBUG
    if ~postfit,  return;  end
    [coeff2, snr_ratio_trend2, snr_ratio_resid2] = snr_bias_trend_fit_aux2 (...
        snr_ratio, indep, ...
        snr_simul_trend, snr_simul_trend2, snr_ratio_trend, ...
        degree, prefit, plotit);
    if plotit,  figure, hold on, plot(snr_ratio_resid, 'b'), plot(snr_ratio_resid2, '.-r'), grid on;  end
    std = nanstdr(snr_ratio_resid);
    std2 = nanstdr(snr_ratio_resid2);
    if (std2 > std),  return;  end
    coeff = coeff2;
    snr_ratio_trend = snr_ratio_trend2;
    snr_ratio_resid = snr_ratio_resid2;
end

%%
function [coeff, snr_fit, snr_resid] = snr_bias_trend_fit_aux (...
snr, indep, degree, prefit, plotit)
    coeff = snr_bias_power_fit (snr, indep, degree, prefit);
    snr_fit = snr_bias_power_eval (coeff, indep);
    snr_resid = snr - snr_fit;
      if plotit,  figure, hold on, plot(indep, snr, '.-r'), plot(indep, snr_fit, '.b');  end
end

%%
function [coeff2, snr_ratio2_trend, snr_ratio_resid2] = snr_bias_trend_fit_aux2 (...
snr_ratio, indep, ...
snr_simul_trend, snr_simul_trend2, snr_ratio_trend, ...
degree, prefit, plotit)
    snr_simul_fringe_magn = snr_simul_trend2 - snr_simul_trend;
      %figure, plot([snr_simul_fringe_magn, snr_simul_trend2, snr_simul_trend])
    %snr_ratio_fringe_magn = snr_ratio - snr_ratio_trend;  % WRONG! includes cosine
    %snr_simul_fringe = snr_simul_trend2 - snr_simul_trend;  % WRONG! doesn't include cosine
    snr_ratio_fringe = snr_ratio - snr_ratio_trend;
      if plotit,  figure, hold on, plot(snr_ratio_fringe, 'b'), plot(snr_simul_fringe_magn, 'r');  end
    snr_simul_fringe_magn2 = snr_simul_fringe_magn ./ snr_simul_trend;
    snr_ratio_fringe2 = snr_ratio_fringe ./ snr_ratio_trend;
      if plotit,  figure, hold on, plot(snr_ratio_fringe2, 'b'), plot(snr_simul_fringe_magn2, 'r');  end
    snr_ratio_fringe3 = snr_ratio_fringe2 ./ snr_simul_fringe_magn2;
    %temp = NaN;  % would lead to high-elev obs being discard.
    temp = 0;
    factor = 3;
    snr_ratio_fringe3(abs(snr_ratio_fringe3) > factor) = temp;
      if plotit,  figure, hold on, plot(snr_ratio_fringe2, 'b'), plot(snr_simul_fringe_magn2, 'r'), plot(snr_ratio_fringe3, 'g');  end
    snr_ratio_fringe4 = snr_ratio_fringe3 .* rmseamp(snr_ratio_fringe);
    snr_ratio2 = snr_ratio_trend + snr_ratio_fringe4;
    snr_ratio2(snr_ratio2 <= 0) = NaN;
      if plotit,  figure, hold on, plot(snr_ratio, 'b'), plot(snr_ratio2, '.-r');  end
    [coeff2, snr_ratio2_trend, snr_ratio_resid2] = snr_bias_trend_fit_aux (...
        snr_ratio2, indep, degree, prefit, plotit);
      if plotit,  figure, hold on, plot(snr_ratio, 'b'), plot(snr_ratio_trend, 'r'), plot(snr_ratio2_trend, 'r', 'LineWidth',2);  end
end

%%
function doplotit (indep, snr_meas, snr_simul_trend, snr_ratio, snr_ratio_trend, snr_resid)
    %%
    f = @(x) 10.^min(floor(log10(range(x)/2)));
    figure
      h = [];
      ha = tight_subplot(4, 1, 0, [0.1 0.025], [0.04 0.04]);
      h(1) = plot(ha(1), indep, snr_meas./f(snr_meas), '.b');
      h(2) = plot(ha(2), indep, snr_simul_trend./f(snr_simul_trend), 'r');
      h(3) = plot(ha(3), indep, snr_ratio./f(snr_ratio), '.', 'Color',[1 1 1]*0.75);
      h(4) = plot(ha(4), indep, snr_resid./f(snr_resid), '.-k');
      hold(ha(3), 'on')
      if isscalar(snr_ratio_trend),  snr_ratio_trend = repmat(snr_ratio_trend, size(indep));  end
      h(5)=plot(ha(3), indep, snr_ratio_trend./f(snr_ratio), 'k', 'Color',[1 1 1]*0.25);
      hline(0, '-k')
      set(h, 'LineWidth',2)
      for i=1:4
        axes(ha(i))  %#ok<LAXES>
        %set_xtick_label_asind2()
        grid(ha(i), 'on')
        set(ha(i), 'XTickLabel',[])
        %set(ha(i), 'YTickLabel',[])
        %xlim(ha(i), sind([5 35]))
      end
      set(ha([2 4]), 'YAxisLocation','right')
      axes(ha(end)) %#ok<MAXES>
        %set_xtick_label_asind2()
        xlabel('Elevation angle (degrees)')
        ylim(min(abs(ylim()))*[-1 +1]*0.5)
      ht(1) = annotation('textbox',...
        [0.0503045910897301 0.853892623716152 0.0468521229868228 0.0729411764705882],...
        'String',{'Measurement'});
      ht(2) = annotation('textbox',...
        [0.0403045910897301 0.629527544351072 0.233564456529318 0.0729411764705881],...
        'String',{'Trend simulation'});
      ht(3) = annotation('textbox',...
        [0.708333333333333 0.425003734827262 0.232142857142857 0.0729411764705881],...
        'String',{'Ratio meas./simul.'}, 'Color',[1 1 1]*0.5);
      ht(4) = annotation('textbox',...
        [0.708333333333333 0.301987861811389 0.232142857142857 0.0729411764705881],...
        'String',{'Polynomial fit'});
      ht(5) = annotation('textbox',...
        [0.708333333333333 0.212702147525674 0.226190476190476 0.0729411764705881],...
        'String',{'Detrended meas.'});
      set(ht, ...
        'FontWeight','bold',...
        'FontName','Arial',...
        'FitBoxToText','off',...
        'EdgeColor','none');
end
