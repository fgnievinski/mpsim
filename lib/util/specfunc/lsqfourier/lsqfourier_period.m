function period = lsqfourier_period (period, time)
%LSQFOURIER_PERIOD: Define periods of trial components for lsqfourier.
% 
% INPUT: 
% - period: spectrum periods (reciprocal of frequencies)
%     [empty] use default trial period domain
%     [vector] use user-specified periods
%     [scalar = NaN] use no tone
%     [struct] modification for default period
%        .ofac: [scalar] oversampling factor
%        .hifac: [scalar] high-frequency factor
%        .lofac: [scalar] low-frequency factor
% - time [vector, real]: observation times

    if isempty(period),  period = struct();  end
    if isstruct(period)
        opt = period;
    else
        % user already specified periods
        return;
    end
    % Trauth MH (2010, p.111) MATLAB recipes for earth sciences, 3rd edn. Springer, Berlin
    % Press et al. (1996, p.572), Numerical Recipes, 3rd ed.
    opt_default = struct(...
        'ofac',4, ... % oversampling factor
        'hifac',1, ... % high-frequency factor
        'lofac',1 ... % low-frequency factor
    );
    opt = structmergenonempty(opt_default, opt);
    num_obs = numel(time);
    
    period_rng = max(time) - min(time);  % range
    period_smp = period_rng / num_obs;  % typical sampling period
    %period_smp = mode(diff(time));
    period_min = period_smp / opt.hifac;  % minimum
    period_stp = period_min / opt.ofac;  % step
    period_max = period_rng / opt.lofac;  % maximum
    
    period = (period_min:period_stp:period_max)';
end    
