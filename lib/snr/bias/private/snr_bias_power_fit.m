function coeff = snr_bias_power_fit (power, indep, degree, prefit, varargin)
    if (nargin < 2),  indep = [];  end
    if (nargin < 3),  degree = [];  end
    if (nargin < 4) || isempty(prefit),  prefit = true;  end
    if isempty(indep) && ~isempty(power)
        assert(degree == 0 || isnan(degree))
        indep = NaN(size(power));
    end
    
    %degree = NaN;  % DEBUG
    db = snr_bias_power_prefit (power, indep, degree, prefit);
    coeff = snr_bias_poly_fit (db, indep, degree);
    if isempty(coeff),  coeff = snr_bias_power_default();  end
end

function db = snr_bias_power_prefit (power, indep, degree, prefit)
    %prefit = false;  % DEBUG
    if ~prefit || (~isempty(degree) && isnan(degree))
        db = decibel_power(power);
        return
    end      
    % (don't use snr_bias_power_eval here because it expects db coeff.)
    coeff_pow = snr_bias_poly_fit (power, indep, degree);
    power2 = snr_bias_poly_eval (coeff_pow, indep, false);
    power2(power2 < 0) = NaN;
    db = decibel_power(power2);
    db = setel(db, isnan(power), NaN);  % CRITICAL!
end
