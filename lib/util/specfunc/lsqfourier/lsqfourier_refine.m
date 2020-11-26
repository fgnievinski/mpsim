function [peak, fit, resid, jacob, colname] = lsqfourier_refine (obs, time, peak, fit, degree, exclude_freq)
%LSQFOURIER_REFINE: Refine tone estimate using least squares.

    if (nargin < 5),  degree = [];  end
    if (nargin < 6),  exclude_freq = [];  end
    
    [jacob, colname] = lsqfourier_jacob_peak (time, peak, degree, exclude_freq);
      
    resid = fit - obs;
    resid = zeronan(resid);
      
    [peak, fit, resid] = lsqfourier_refine_aux (...
        peak, fit, resid, jacob, colname);
      
    peak.complex = peak.amplitude*exp(1i*peak.phase*pi/180);
    peak.power = peak.amplitude^2;
end

