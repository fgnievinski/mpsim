function [peak, fit, resid] = mplsqfourier_refine_aux (...
peak, fit, resid, jacob, colname, wavelength)
    if (nargin < 6),  wavelength = [];  end
    wavelength = get_gnss_wavelength (wavelength);
    
    [peak, fit, resid] = lsqfourier_refine_aux (...
        peak, fit, resid, jacob, colname);
    
    peak.height = peak.freq * wavelength / 2;
end

