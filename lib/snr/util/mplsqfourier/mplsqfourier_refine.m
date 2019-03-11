function [peak, fit, resid, jacob] = mplsqfourier_refine (obs, elev, peak, fit, ...
wavelength, degree, exclude_height)
    if (nargin < 5),  wavelength = [];  end
    if (nargin < 6),  degree = [];  end
    if (nargin < 7),  exclude_height = [];  end
    wavelength = get_gnss_wavelength (wavelength);
    
    sine = sind(elev);
    [peak, fit, resid, jacob] = lsqfourier_refine (obs, sine, peak, fit, ...
        degree, exclude_height);
        
    peak.height = peak.freq * wavelength / 2;
end

