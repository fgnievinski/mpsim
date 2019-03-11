function period = lsqfourier_period (period, time)
%LSQFOURIER_PERIOD: Define periods of trial components for lsqfourier.
% 
% INPUT: 
% - period:
%     [empty] use default trial period domain
%     [vector] use user-specified tones
%     [scalar = NaN] use no tone
%     [struct] modification for default period
%        .ofac: [scalar] oversampling factor
%        .hifac: [scalar] high-frequency factor

    if isempty(period),  period = struct();  end
    if ~isstruct(period),  return;  end
    period_opt = period;
    % Trauth MH (2010, p.111) MATLAB recipes for earth sciences, 3rd edn. Springer, Berlin
    % Press et al. (1996, p.572), Numerical Recipes, 3rd ed.
    period_opt_default = struct(...
        'ofac',4, ... % oversampling factor
        'hifac',1 ... % high-frequency factor
    );
    period_opt = structmergenonempty(period_opt_default, period_opt);
    num_obs = numel(time);
    period_max = max(time) - min(time);
    %period_nyq = 2 * period_max / num_obs;  % WRONG!
    period_nyq = 0.5 * period_max / num_obs;
    period_min = period_nyq / period_opt.hifac;
    period_step = period_min / period_opt.ofac;
    period = (period_min:period_step:period_max)';
end    
