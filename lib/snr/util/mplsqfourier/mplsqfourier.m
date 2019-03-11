function [peak, spec, fit, fit2, fit3, J, wavelength] = mplsqfourier (obs_and_std, elev, ...
height, wavelength, degree, opt, J, return_fits)
    if (nargin < 3),  height = [];  end
    if (nargin < 4),  wavelength = [];  end
    if (nargin < 5),  degree = [];  end
    if (nargin < 6),  opt = [];  end
    if (nargin < 7),  J = [];  end
    if (nargin < 8),  return_fits = [];  end
    wavelength = get_gnss_wavelength (wavelength);
    if isequaln(opt, NaN)  % legacy interface
    %if isnan(opt, NaN)  % WRONG! (breaks with opt=struct())
        error ('matlab:mplsqfourier:badInput', ...
          'Input interface has changed; 5th and 6th arguments has been swapped.');
    end
    
    height = mplsqfourier_height (height);
    freq = 2 * height ./ wavelength;
    period = 1./freq;
    sine = sind(elev);
    
    s = warning('off', 'MATLAB:rankDeficientMatrix');
    [peak, spec, fit, fit2, fit3, J] = lsqfourier (obs_and_std, sine, ...
        period, degree, opt, J, return_fits);    
    warning(s)

    %spec.height = height;  % WRONG! (it might have been refined)
    spec.height = spec.freq * wavelength / 2;
    peak.height = spec.height(peak.ind);
end
