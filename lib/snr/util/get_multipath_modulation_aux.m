function [var, trend, den] = get_multipath_modulation_aux (composite_pow, ...
phasor_direct, phasor_reflected, ...
detrendit_all, normalizeit_all, phasor_reflected2, ...
detrendit_again, normalizeit_again, elev, degree, p)
    if (nargin < 4) || isempty(detrendit_all),  detrendit_all = true;  end
    if (nargin < 5) || isempty(normalizeit_all),  normalizeit_all = true;  end
    if (nargin < 6),  phasor_reflected2 = [];  end
    if (nargin < 7) || isempty(detrendit_again),  detrendit_again = false;  end
    if (nargin < 8) || isempty(normalizeit_again),  normalizeit_again = false;  end
    if (nargin < 9) || isempty(elev),  elev = reshape(1:numel(composite_pow), size(composite_pow));  end
    if (nargin <10) || isempty(degree),  degree = 2;  end
    if (nargin <11) || isempty(p),  p = 2;  end
    % mp_pow and phasor_reflected already incorporate biases -- 
    % reflected or not (see snr_fwd_reflected and snr_fwd_signal2snr).
    
    dir_pow = get_power(phasor_direct);
    ref_pow = get_power(phasor_reflected);
    trend = dir_pow + ref_pow;
    if ~detrendit_all,  trend = nanmedian(trend);  end
    var = composite_pow - trend;
    if detrendit_again,  var = polyfitvaldiff (elev, var, degree);  end
    
    ref_pow2 = ref_pow;
    if ~isempty(phasor_reflected2),  ref_pow2 = get_power(phasor_reflected2);  end
    den = 2.*sqrt(dir_pow .* ref_pow2);
    if ~normalizeit_all,  den = nanmedian(den);  end
    var = var ./ den;
    if normalizeit_again,  var = var ./ rmseamp(var);  end
    var(~isfinite(var)) = NaN;
    
    if (p ~= 2)
        var = sign(var) .* abs(var).^(p/2);
        if detrendit_again,  var = polyfitvaldiff (elev, var, degree);  end
    end
end

function dy0 = polyfitvaldiff (x0, y0, n)
    idx = isnan(x0) | isnan(y0);
    x = x0(~idx);
    y = y0(~idx);
    % force centering & scaling:
    [coeff, ignore, mu] = polyfit(x, y, n); %#ok<ASGLU>
    dy0 = y0 - polyval(coeff, x0, [], mu);
end
