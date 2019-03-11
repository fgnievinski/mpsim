function [peak, snr_detrended_fit, snr_detrended, J] = snr_bias_sinusoid_fit (...
snr_detrended, elev, ...
degree, refine_peak, ...
height_domain, wavelength, J, plotit)
    if (nargin < 3) || isempty(degree),  degree = 2;  end
    if (nargin < 4) || isempty(refine_peak),  refine_peak = false;  end
    if (nargin < 5),  height_domain = [];  end
    if (nargin < 6),  wavelength = [];  end
    if (nargin < 7),  J = [];  end
    if (nargin < 8) || isempty(plotit),  plotit = false;  end
    
    if ~isnan(degree)
        % This is often necessary because the direct power bias 
        % detrending is a fit over a possibly different range of elevation 
        % angles (normally the full [0 90]), whereas here we normally use 
        % a limited range (e.g., [0 35]).
        snr_trend2 = nanpolyfitval(elev, snr_detrended, degree);
        snr_detrended2 = snr_detrended - snr_trend2;
          if plotit,  figure, hold on, plot(elev, snr_detrended, 'b'), plot(elev, snr_detrended2, 'g');  end
        snr_detrended = snr_detrended2;
    end
    
    [peak, spec, snr_detrended_fit, ignore, ignore, J] = mplsqfourier (...
        snr_detrended, elev, height_domain, wavelength, [], [], J);  %#ok<ASGLU>
      if plotit,  figure, hold on, plot(sind(elev), snr_detrended,  '.-k'), plot(sind(elev), snr_detrended_fit,  '-r', 'LineWidth',2), grid on,  end % DEBUG
      %figure, stem(spec.height, spec.power)  % DEBUG
      
    if ~refine_peak,  return;  end
    for i=1:double(refine_peak)  % (refine_peak might be boolean.)
        [peak, snr_detrended_fit] = mplsqfourier_refine (...
            snr_detrended, elev, peak, snr_detrended_fit, wavelength);
    end
end
