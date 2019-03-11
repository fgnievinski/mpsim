function [sol, spec, resid, fit, jacob, jacobe] = mplsqfourier_multiple (obsstd, elev, ...
height_input, wavelength, num_extra, degree, exclude_height, rms_method, jacobe, refine, method)
%MPLSQFOURIER: Multipath LSSA, with detailed information about multiple peaks.

    if (nargin < 03),  height_input = [];  end
    if (nargin < 04),  wavelength = [];  end
    if (nargin < 05) || isempty(num_extra),  num_extra = 1;  end
    if (nargin < 06) || isempty(degree),  degree = 2;  end
    if (nargin < 07),  exclude_height = [];  end
    if (nargin < 08),  rms_method = [];  end
    if (nargin < 09),  jacobe = [];  end
    if (nargin < 10),  refine = true;  end
    if (nargin < 11),  method = [];  end
    if isempty(method)
        method = 'iterated';
        %method = 'complete';  % EXPERIMENTAL
        method = {method, [], 1+num_extra};
    end

    [peak1, spec, fit1, ignore, ignore, jacobe] = mplsqfourier (obsstd, elev, ...
        height_input, wavelength, degree, method, jacobe, false); %#ok<ASGLU>
      
    [peak, fit, jacob, colname] = mplsqfourier_multiple_aux (elev, peak1, spec, fit1, ...
        num_extra, degree, exclude_height);

    if iscell(obsstd),  obs = obsstd{1};  else  obs = obsstd;  end
    resid = fit - obs;
    resid = zeronan(resid);

    sol = struct();
    sol.extra = struct();
    sol.extra.name = colname;
    
    if refine
      [sol.val, fit, resid] = mplsqfourier_refine_aux (...
          peak, fit, resid, jacob, colname, wavelength);
    end
    
    [sol.unc, sol.extra.cov, sol.extra.rms] = mplsqfourier_uncertainty_aux (...
        resid, jacob, colname, wavelength, rms_method);
end

%%
% function [resid, jacob, colname] = mplsqfourier_multiple_aux (...
% obs, elev, peak, spec, fit, num_extra, degree, exclude_height)
function [peak, fit, jacob, colname] = mplsqfourier_multiple_aux (...
elev, peak1, spec, fit1, num_extra, degree, exclude_height)
    [jacob, colname] = mplsqfourier_design (elev, peak1, degree, exclude_height);

    name = {'amplitude','phase','freq'};
    peak = getfields(peak1, [name, polyname(peak1.poly)]);
    fit = fit1;
    
    degreei = NaN;
    exclude_heighti = false;
    sine = sind(elev);
    for i=(1+(1:num_extra))
        peaki = mplsqfourier_spec2peak (spec, i);
        if (peaki.ind <= 2)
            warning('matlab:mplsqfourier_multiple:aliasingLow', ...
                ['Low-frequency secondary peak sinusoid detected '...
                 '(likely co-linear with low-order polynomial); '...
                 'increasing the detrending polynomial degree recommended.'])
        end

        [jacobi, colnamei] = mplsqfourier_design (elev, peaki, degreei, exclude_heighti);
        
        colnamei = strcat(colnamei, num2str(i));
        jacob = horzcat(jacob, jacobi);  %#ok<AGROW>
        colname = horzcat(colname, colnamei);  %#ok<AGROW>
        
        fiti = eval_sinusoid (peaki.amplitude, peaki.phase, peaki.freq, sine);    
        fit = fit + fiti;
        
        namei = strcat(name, num2str(i));
        peaki = renfields(peaki, name, namei);
        peak = structmerge(peak, getfields(peaki, namei));
    end
end
