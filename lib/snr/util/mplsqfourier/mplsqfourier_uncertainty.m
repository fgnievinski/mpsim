function [unc, cov, rms, resid, jacob] = mplsqfourier_uncertainty (obs, elev, peak, fit, ...
wavelength, degree, exclude_height, rms_method)
    if (nargin < 5),  wavelength = [];  end
    if (nargin < 6),  degree = [];  end
    if (nargin < 7),  exclude_height = [];  end
    if (nargin < 8),  rms_method = [];  end

    [jacob, colname] = mplsqfourier_design (elev, peak, degree, exclude_height);
    
    resid = fit - obs;
    resid = zeronan(resid);
    
    [unc, cov, rms] = mplsqfourier_uncertainty_aux (...
        resid, jacob, colname, wavelength, rms_method);
end

