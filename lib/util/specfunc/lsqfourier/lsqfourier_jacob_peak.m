function [jacob, colname] = lsqfourier_jacob_peak (time, peak, degree, exclude_freq)
%LSQFOURIER_JACOB_PEAK: Extended Jacobian matrix for LSSA (peak only), including detrending polynomial.

    if (nargin < 3) || isempty(degree),  degree = 0;  end
    if (nargin < 4) || isempty(exclude_freq),  exclude_freq = false;  end
    
    [~, ~, dS_dA, dS_dp, dS_df] = eval_sinusoid (...
        peak.amplitude, peak.phase, peak.freq, time);
    
    jacob = [dS_dA, dS_dp];
    colname = {'amplitude','phase'};
    if ~exclude_freq
        jacob = [jacob, dS_df];
        colname{end+1} = 'freq';
    end
    jacob = [jacob, polydesign1a(time, polyd2c(degree))];
    colname = [colname polyname(polyd2c(degree))];
    jacob = zeronan(jacob);
end
