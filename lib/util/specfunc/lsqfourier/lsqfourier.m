function [peak, spec, fit, fit2, fit3, J] = lsqfourier (obs, time, ...
period, degree, opt, J, return_fits)
%LSQFOURIER: Least-squares spectral analysis (LSSA).
% 
% SYNTAX:
%    lsqfourier (obs, time)
%    [peak, spec] = lsqfourier (...)
%    lsqfourier (obs, time, period, degree, opt, J, return_fits)
%    [peak, spec, fit, fit2, fit3, J] = lsqfourier (...)
% 
% INPUT: none    
%    obs: [vector] observation values (normally in volts; real-valued)
%    time: [vector] observation times (normally in seconds; real-valued)
%
% OUTPUT:
%    peak: [struct] spectral peak or strongest tone
%    spec: [struct] spectrum
%
% EXAMPLE:
%    num_obs = 10;
%    time = linspace(0, 1, num_obs)';
%    freq = rand();
%    ampl = rand();
%    phase = rand()*360;
%    obs = ampl * cos(2*pi*freq*time + phase*pi/180);
%    [peak, spec] = lsqfourier(obs, time);
%    figure, stem(spec.period, spec.power)
%    hold on, plot(peak.period, peak.power, '.r')
%
% REMARKS:
% - Input "obs" might be a cell containing two vectors, observations and uncertainties.
%    Note: in this case, a weighted least squares fit is performed.
% - Output "peak" contains the following fields:
%    .complex: [scalar] spectral coefficient (complex-valued)
%    .power: [scalar] spectral power density (real-valued; normally in V^2/Hz)
%    .amplitude: [scalar] square-root of spectral power density (real-valued)
%    .phase: [scalar] phase (in degrees)
%    .period: [scalar] period (normally in seconds)
%    .freq: [scalar] ordinary frequency (normally in hertz)
%    .ind: [scalar] index of peak tone in spectrum
%    .poly*: [scalar] detrending polynomial coefficients
% - Output "spec" contains the following fields:
%    .complex: [vector] spectral coefficients (complex-valued)
%    .power: [vector] spectral power density (real-valued; normally in V^2/Hz)
%    .amplitude: [vector] square-root of spectral power density (real-valued)
%    .phase: [vector] phase (in degrees)
%    .period: [vector] period (normally in seconds)
%    .freq: [vector] ordinary frequency (normally in hertz)
%    .order: [vector] index of tones, from strongest to weakest
%    .order_inv: [vector] reversee index of tones.
% - Input also includes the following additional arguments (optional):
%    period: periods of tones to be tried (see lsqfourier_period.m for details)
%    degree: [scalar] degree of detrending polynomial:
%      degree=NaN: disable detrending
%      degree=0: fit and subtract mean only (zeroth order polynomial)
%      degree=1: fit and subtract linear trend (first order polynomial)
%      degree>1: fit and subtract arbitrary trend (nth order polynomial)
%    opt: options
%      opt.method: [char] estimation method ('')
%        opt.method = 'simultaneous' or 'in context': all trial tones together
%        opt.method = 'independent' or 'out of context': all trial tones, one at a time (default)
%        opt.method = 'iterated': leading tones only, one tone at a time, applied to residuals
%        opt.method = 'complete': 'iterated' followed by 'simultaneous'
%      opt.tol: [scalar] tolerance for stopping iterated
%        Note: if opt.tol is negative, then it's an absolute tolerance,
%        otherwise it's multiplied by the RMS of residuals.
%      opt.max_num_components: [scalar] maximum number of leading tones to estimate
%      Note: if opt is char, then it's interpreted as opt.method only.
%    J: [matrix] Jacobian; it can be reused for a same period vector.
%    return_fits: [scalar] calculate predicted observations? (logical/boolean)
% - Outpur also includes the following additional arguments:
%    fit: [vector] predicted observations produced by the peak tone only
%    fit2: [vector or matrix] predicted observations produced by the spectrum
%      if opt.method = 'simultaneous': fit2 is a vector of the sum of all tones together
%      if opt.method = 'independent': fit2 is a matrix with one column for each trial tone
%      if opt.method = 'iterated': fit2 is a matrix with one column for each leading tone
%      if opt.method = 'complete': fit2 is a vector of the sum of all leading tones together
%    fit3: [matrix] predicted observations produced by the spectrum
%      if opt.method = 'iterated': fit3 with the cumulative sum of ordered leading tones.
%      otherwise: fit3 is a NaN matrix.
%    J: [matrix] Jacobian; it can be reused for a same period vector.
% - Terminology: a "tone" is synonym with a sinusoid of constant frequency, phase-shift, and amplitude.
% 
% For background, see section 1.9, "Fourier Series as Least-Squares" in 
% Prof. Wunsch's "Inference from Data and Models" lecture notes, 
% available at the MIT Open Courseware website:
%   <http://ocw.mit.edu/courses/earth-atmospheric-and-planetary-sciences/12-864-inference-from-data-and-models-spring-2005/lecture-notes/tsamsfmt_1_9.pdf>
%   <http://ocw.mit.edu/courses/earth-atmospheric-and-planetary-sciences/12-864-inference-from-data-and-models-spring-2005/lecture-notes/tsamsfmt_1_6.pdf>
% 
% The distinction between in- and out-of-context is explained in
% Caymer's PhD dissertation:
%   Craymer, M.R., The Least Squares Spectrum, Its Inverse Transform and
%   Autocorrelation Function: Theory and Some Applications in Geodesy, 
%   Ph.D. Dissertation, University of Toronto, Canada (1998).
%   <ftp://ftp.geod.nrcan.gc.ca/pub/GSD/craymer/pubs/thesis1998.pdf>
% 
% Additional discussion and case studies are given in:
%   D. Wells, P.Vanicek and S. Pagiatakas, "Least Squares Spectral 
%   Analysis Revisited", Dept. of Surveying Engineering Technical 
%   Report No. 84, 1985, Available at <http://gge.unb.ca/Pubs/TR84.pdf>
% 
% An implementation in Fortran and sample datasets are available at:
%   <ftp://ftp.geod.nrcan.gc.ca/pub/GSD/craymer/software/lssa/LSSA.DOC>

    if (nargin < 3),  period = [];  end
    if (nargin < 4),  degree = [];  end
    if (nargin < 5),  opt = [];  end
    if (nargin < 6),  J = [];  end
    if (nargin < 7),  return_fits = [];  end
    if isempty(return_fits),  return_fits = true;  end
    if (nargout < 3),  return_fits = false;  end
    
    %% call auxiliary function to do the main work:
    [coeff, fit2, J, period, degree, opt, input_iscolvec] = lsqfourier_aux (obs, time, period, degree, opt, J);
    
    %% get power and phase of complex-valued spectral components:
    spec = struct();
    spec.complex = coeff;
    spec.power = get_power(coeff);  % if obs are in power-units, then this is power^2.
    spec.amplitude = sqrt(spec.power);  % if obs are in power-units, then this is also in power units.
    spec.phase = get_phase(coeff);
    spec.phase = angle_range_positive(spec.phase);
    spec.period = period;
    spec.freq = 1./period;
    
    %% sort spectrum and extract peak:
    temp = spec.power;  temp(isnan(temp)) = -Inf;
    [spec.order, spec.order_inv] = argsortinv(temp, 'descend');    
    peak = lsqfourier_spec2peak (spec);
      assert(peak.ind == argmax(spec.power))
    if (nargout < 3),  return;  end
      
    %% store polynomial trend:
    if iscell(obs),  obs = obs{1};  end
    %[trend, peak.poly] = nanpolyfitval(time, obs, degree);
    [trend, poly, ~, ~] = nanpolyfitval(time, obs, degree);  % allow time centering & scaling
    peak.poly = poly;
    peak = structmerge(peak, poly2struct(poly));

    %% calculate predicted observations:
    fit = eval_sinusoid (peak.amplitude, peak.phase, peak.freq, time);    
    fit = fit + trend;
    if (nargout < 5) || ~return_fits,  fit3 = [];  return;  end
    fit3 = NaN(size(fit2));
    if any(strcmpi(opt.method, {'iterated', 'iterative', 'iteratively'}))
        trend2 = trend;  if ~input_iscolvec,  trend2 = trend2';  end
        fit2 = minus_all(fit2, trend2);
        fit3 = cumsum(fit2(:,spec.order), 2);
        fit3 = fit3(:,spec.order_inv);
        fit3 = plus_all(fit3, trend2);
        fit2 = plus_all(fit2, trend2);
    end
end
