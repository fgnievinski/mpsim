function [deriv, peak] = mplsqfourierderiv (power, elev, height_mid, wavelength, ...
height_eps, height_lim_rel, power_eps_rel2, shifted_count)
    if ~any(power < 0) && any(elev < 0)
       warning('snr:mplsqfourierderiv:badInput', 'Check order of arguments.');
    end
    if (nargin < 3) || isempty(height_mid),  height_mid = 2;  end
    if (nargin < 4),  wavelength = [];  end
    if (nargin < 5) || isempty(height_eps),  height_eps = 1e-5;  end
    if (nargin < 6) || isempty(height_lim_rel),  height_lim_rel = 1e-2;  end
    if (nargin < 7) || isempty(power_eps_rel2),  power_eps_rel2 = 1/100;  end
    if (nargin < 8) || isempty(shifted_count),  shifted_count = 0;  end
    if isscalar(height_lim_rel),  height_lim_rel = [-1,+1] * height_lim_rel;  end

    N = numel(elev);  assert(numel(power) == N)    
    
    peak = struct();
    peak.info = struct();
    peak.info.elev = elev;
    peak.info.power = power;
    
    peak.info.height_mid = height_mid;
    peak.info.height_eps = height_eps;
    peak.info.height_lim_rel = height_lim_rel;
    peak.info.height_lim = peak.info.height_mid + height_lim_rel;
    peak.info.height_domain = (peak.info.height_lim(1):peak.info.height_eps:peak.info.height_lim(2))';

    peak.height = struct();
    peak.phase = struct();
    peak.power = struct();
    [peak_mid, spectrum_mid, ignore, ignore, ignore, J] = mplsqfourier (...
      power, elev, peak.info.height_domain, wavelength, NaN); %#ok<ASGLU>
    peak.height.mid = peak_mid.height;
    peak.phase.mid = peak_mid.phase;
    peak.power.mid = sqrt(peak_mid.power);
    %peak.power.mid = peak_mid.power;  % WRONG! this would be power^2, since we input power!
    
    %figure, plot(spectrum_mid.height, spectrum_mid.power)  % DEBUG
    shifted_max = 5;
    idx = (peak.info.height_lim == peak.height.mid);
    if any(idx)
        shifted_count = shifted_count + 1;
        if (shifted_count > shifted_max)
            error('snr:mplsqfourierderiv:smallDomainMax', ...
                'Maximum number of iterations to shift mid height.');
        end
        height_mid = peak.info.height_lim(idx);
        warning('snr:mplsqfourierderiv:smallDomain', ...
            'Shifting mid height to include peak height.')
        [deriv, peak] = mplsqfourierderiv (power, elev, height_mid, wavelength, ...
            height_eps, height_lim_rel, power_eps_rel2);
        return;
    end

    temp = NaN(N,1);
    peak.height.lo = temp;
    peak.height.hi = temp;
    peak.phase.lo = temp;
    peak.phase.hi = temp;
    peak.power.lo = temp;
    peak.power.hi = temp;
    peak.info.power_eps = power_eps_rel2*rmseamp(power)*numel(power);
    peak.info.wavelength = wavelength;
    for i=1:N
      obs_lo = setel(power, i, power(i) - peak.info.power_eps); 
      obs_hi = setel(power, i, power(i) + peak.info.power_eps); 
      peak_lo = mplsqfourier (obs_lo, elev, peak.info.height_domain, peak.info.wavelength, NaN, [], J);
      peak_hi = mplsqfourier (obs_hi, elev, peak.info.height_domain, peak.info.wavelength, NaN, [], J);
      peak.height.lo(i) = peak_lo.height;
      peak.height.hi(i) = peak_hi.height;
      peak.phase.lo(i)  = peak_lo.phase;
      peak.phase.hi(i)  = peak_hi.phase;
      peak.power.lo(i)  = sqrt(peak_lo.power);
      peak.power.hi(i)  = sqrt(peak_hi.power);
    end
    peak.height.delta = peak.height.hi - peak.height.lo;
    peak.phase.delta  = peak.phase.hi  - peak.phase.lo;
    peak.power.delta  = peak.power.hi  - peak.power.lo;
    %k = 2*peak.info.power_eps;
    %k = 2*peak.info.power_eps .* 2*abs(gradient(elev)) ./ range(elev);  % WRONG!
    k = 2*peak.info.power_eps .* 2*abs(gradient(sind(elev))) ./ range(sind(elev));
    peak.height.deriv = peak.height.delta ./ k;
    peak.phase.deriv  = peak.phase.delta ./ k;
    peak.power.deriv  = peak.power.delta ./ k;

    deriv = struct();
    deriv.height = peak.height.deriv;
    deriv.phase  = peak.phase.deriv;
    deriv.power  = peak.power.deriv;
    
    return;  % DEBUG
    %figure, plot(elev, obs, '.-k'), hold on, plot(elev, obs_lo, 'or'), 
    figure
      plot(peak.info.elev, peak.info.power, '.-k')
      xlabel('Elevation angle (degrees)')
      ylabel('P')
      grid on
      xlim([min(peak.info.elev) max(peak.info.elev)])
      fixfig()
       
    figure
      hold on
      plot(peak.info.elev, peak.power.deriv, 'o-r')
      plot(peak.info.elev, peak.info.power, '.-k')
      xlabel('Elevation angle (degrees)')
      ylabel('$P(e), \partial{P_\mathrm{M}}/\partial{P(e)}$', 'Interpreter','latex')
      grid on
      xlim([min(peak.info.elev) max(peak.info.elev)])
      fixfig()
    %figure, plot(elev, obs, '.-k'), hold on, plot(elev, peak.power.deriv, 'or'), 
     
    k = mean(peak.phase.deriv([1,end]) ./ peak.height.deriv([1 end]));
    figure
      hold on
      plot(peak.info.elev, peak.phase.deriv, 'o-k')
      plot(peak.info.elev, peak.height.deriv*k, '.-r');
      xlabel('Elevation angle (degrees)')
      ylabel('\partial{(\Phi,H)}/\partial{P(e)}')
      grid on
      xlim([min(peak.info.elev) max(peak.info.elev)])
      fixfig()
      
    figure
      plot(peak.info.elev, peak.height.deriv, '.-k')
      xlabel('Elevation angle (degrees)')
      ylabel('\partial{H}/\partial{P(e)}')
      grid on
      xlim([min(peak.info.elev) max(peak.info.elev)])
      fixfig()
      
    figure
      plot(peak.info.elev, peak.phase.deriv, '.-k')
      xlabel('Elevation angle (degrees)')
      ylabel('\partial{\Phi}/\partial{P(e)}')
      grid on
      xlim([min(peak.info.elev) max(peak.info.elev)])
      fixfig()
    
    k  = rmse(peak.power.deriv) / rmse(peak.height.deriv);
    k2 = rmse(peak.power.deriv) / rmse(peak.phase.deriv);
    k2 = -k2;
    figure
      hold on
      %plot(peak.info.elev, flipud(peak.height.deriv*-k), '-y');
      plot(peak.info.elev, peak.height.deriv*k, 's-r');
      plot(peak.info.elev, peak.phase.deriv*k2, 'o-b')
      plot(peak.info.elev, peak.power.deriv, 'd-k')
      xlabel('Elevation angle (degrees)')
      ylabel('$\partial{(-H_\mathrm{M},\phi_\mathrm{M},P_\mathrm{M})}/\partial{P(e)}$', 'Interpreter','latex')
      grid on
      xlim([min(peak.info.elev) max(peak.info.elev)])
      fixfig()
end
