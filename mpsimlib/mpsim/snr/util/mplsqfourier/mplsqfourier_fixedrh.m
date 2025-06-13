function [power, phaseshift, snr_fit, snr_detrend, snr_resid, pnr] = mplsqfourier_fixedrh (...
snr_obs, elev, height_input, wavelength, degree, restore_trend)
    if (nargin < 4),  wavelength = [];  end
    if (nargin < 5) || isempty(degree),  degree = 2;  end
    if (nargin < 6) || isempty(restore_trend),  restore_trend = true;  end
    idx = ~isnan(snr_obs) & ~isnan(elev);
    temp = NaN(size(idx));
    snr_fit     = temp;
    snr_detrend = temp;
    snr_resid   = temp;
    [power, phaseshift, snr_fit(idx), snr_detrend(idx), snr_resid(idx), pnr] = mplsqfourier_fixedrh_aux (...
        snr_obs(idx), elev(idx), height_input, wavelength, degree, restore_trend);
end

%%
function [power, phaseshift, snr_fit, snr_detrend, snr_resid, pnr] = mplsqfourier_fixedrh_aux (...
snr_obs, elev, height_input, wavelength, degree, restore_trend)
    sine = sind(elev);

    wavelen = get_gnss_wavelength (wavelength);
    wavenum = 2*pi/wavelen;
    wavenum = wavenum * 180/pi;  % convention of phase in degrees
    delay = 2*height_input.*sine;
    phase = delay*wavenum;
    
    ac = cosd(phase); 
    as = sind(phase);    
    J = [ac as];  J(:,3) = 1;
    snr_trend = nanpolyfitval(sine, snr_obs, degree);
    snr_detrend = snr_obs - snr_trend;
    
    %if (nargout < 3),  return;  end
    p = J\snr_detrend;
    pc = p(1);
    ps = p(2);
    power = pc^2+ps^2;
    %phaseshift = atan2d(ps, pc);
    phaseshift = atan2d(ps, pc);
    phaseshift = angle_range_positive(-phaseshift + 360);
    %phaseshift = get_phase(complex(pc, ps)); 
    mean = p(3);
    
    sinusoid = J * p;
    checkit = false;
    %checkit = true;  % DEBUG
    if checkit
      sinusoid2 = mean + sqrt(power) * cosd(phase+phaseshift);
      figure, hold on, plot(sinusoid, 'o-b'), plot(sinusoid2, '.-r')
      temp = max(abs(sinusoid2-sinusoid));
      assert(temp < sqrt(eps()))
    end
    
    if restore_trend
      snr_fit = sinusoid + snr_trend;
      snr_resid = snr_obs - snr_fit;
    else
      snr_fit = sinusoid;
      snr_resid = snr_detrend - snr_fit;
    end
    pnr = nanrmse(snr_resid) / nanrmse(snr_detrend);
end
