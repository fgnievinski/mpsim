function [sol, spec, resid, fit, jacob, jacobe] = lsqfourier_multiple (obs, time, ...
period, degree, opt, jacobe)
%LSQFOURIER: LSSA, with detailed information about multiple peaks.

    if (nargin < 3),  period = [];  end
    if (nargin < 4),  degree = [];  end
    if (nargin < 5),  opt = [];  end
    if (nargin < 6),  jacobe = [];  end

    if isempty(degree),  degree = 0;  end    
    if isempty(opt),  opt = struct();  end
    assert(isstruct(opt))
    %if isfieldempty(opt, 'method'),  opt.method = 'independent';  end  % WRONG!
    if isfieldempty(opt, 'method'),  opt.method = 'iterated';  end
    if isfieldempty(opt, 'tol'),  opt.tol = 1/100;  end
    if isfieldempty(opt, 'max_num_components'),  opt.max_num_components = 1+1;  end    
    if isfieldempty(opt, 'check_jacob'),  opt.check_jacob = true;  end    
    if isfieldempty(opt, 'exclude_freq'),  opt.exclude_freq = false;  end    
    if isfieldempty(opt, 'rms_method'),  opt.rms_method = [];  end    
    if isfieldempty(opt, 'refine'),  opt.refine = true;  end    

    [peak1, spec, fit1, ignore, ignore, jacobe] = lsqfourier (obs, time, ...
        period, degree, opt, jacobe, false); %#ok<ASGLU>
      
    [peak, fit, jacob, colname] = lsqfourier_multiple_aux (time, peak1, spec, fit1, ...
        degree, opt.max_num_components, opt.exclude_freq);

    if iscell(obs),  obs = obs{1};  end
    resid = fit - obs;
    resid = zeronan(resid);

    sol = struct();
    sol.extra = struct();
    
    if opt.refine
      [sol.val, fit, resid] = lsqfourier_refine_aux (...
          peak, fit, resid, jacob, colname);
    end
    
    [sol.unc, sol.extra.cov, sol.extra.rms] = lsqfourier_uncertainty_aux (...
        resid, jacob, colname, opt.rms_method);
end

%%
function [peak, fit, jacob, colname] = lsqfourier_multiple_aux (...
time, peak1, spec, fit1, degree, max_num_components, exclude_freq)
    [jacob, colname] = lsqfourier_jacob_peak (time, peak1, degree, exclude_freq);
    peak = getfields(peak1, colname);
    fit = fit1;

    name0 = {'amplitude','phase','freq'};
    %peak = getfields(peak1, [name0, polyname(peak1.poly)]);
    
    degreei = NaN;
    exclude_freqi = false;
    for i=2:max_num_components
        peaki = lsqfourier_spec2peak (spec, i);
        if (peaki.ind <= 2)
            warning('matlab:lsqfourier_multiple:aliasingLow', ...
                ['Low-frequency secondary peak sinusoid detected '...
                 '(likely co-linear with low-order polynomial); '...
                 'increasing the detrending polynomial degree recommended.'])
        end

        [jacobi, colnamei] = lsqfourier_jacob_peak (time, peaki, degreei, exclude_freqi);
        
        colnamei = strcat(colnamei, num2str(i));
        jacob = horzcat(jacob, jacobi);  %#ok<AGROW>
        colname = horzcat(colname, colnamei);  %#ok<AGROW>
        
        fiti = eval_sinusoid (peaki.amplitude, peaki.phase, peaki.freq, time);    
        fit = fit + fiti;
        
        namei = strcat(name0, num2str(i));
        peaki = renfields(peaki, name0, namei);
        peak = structmerge(peak, getfields(peaki, namei));
    end
end
