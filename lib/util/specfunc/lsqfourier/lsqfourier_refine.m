function [peak, fit, resid, jacob] = lsqfourier_refine (obs, time, peak, fit, degree, exclude_height)
%LSQFOURIER_REFINE: Refine frequency estimate using least squares.

    if (nargin < 5),  degree = [];  end
    if (nargin < 6),  exclude_height = [];  end
    
    [jacob, colname] = lsqfourier_design (time, peak, degree, exclude_height);
      
    resid = fit - obs;
    resid = zeronan(resid);
      
    [peak, fit, resid] = lsqfourier_refine_aux (...
        peak, fit, resid, jacob, colname);
      
    peak.complex = peak.amplitude*exp(1i*peak.phase*pi/180);
    peak.power = peak.amplitude^2;
end

