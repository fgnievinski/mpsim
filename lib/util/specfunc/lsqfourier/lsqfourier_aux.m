function [param, fit, J_original, period, degree, opt] = lsqfourier_aux (obs, time, ...
period, degree, opt, J_original)    
%LSQFOURIER_AUX: Auxiliary function for LSSA.

    %% parse input:
    if (nargin < 3),  period = [];  end
    if (nargin < 4),  degree = [];  end    
    if (nargin < 5),  opt = [];  end
    if (nargin < 6),  J_original = [];  end
    if isempty(degree),  degree = 0;  end    
    if islogical(degree)  % legacy interface.
        demean = degree;
        if demean,  degree = 0;  else  degree = NaN;  end
    end
    if isempty(opt),  opt = struct();  end
    if ischar(opt),  opt = {opt};  end  % legacy interface
    if iscell(opt)  % legacy interface
        opt(end+1:3) = {[]};
        opt = cell2struct(opt, {'method','tol','max_num_components'}, 2);
    end
    if isfieldempty(opt, 'method'),  opt.method = 'independent';  end
    if isfieldempty(opt, 'tol'),  opt.tol = 1/100;  end
    if isfieldempty(opt, 'max_num_components'),  opt.max_num_components = Inf;  end    
    if iscell(obs),  [obs, std] = deal(obs{:});  else  std = [];  end
    if ~isreal(obs)
        error('matlab:lsqfourier:nonReal', 'Complex-valued data not supported.');
    end    

    %% discard invalid observations:
    assert(isvector(time))
    assert(isvector(obs))
    time = time(:);
    obs  = obs(:);
    idx_isnan = isnan(obs) | isnan(time);
    time_original = time;  time(idx_isnan) = [];  obs(idx_isnan) = [];

    %% define periods of trial tones:
    period = lsqfourier_period (period, time);
    if isnan(period),  period = [];  end
    period = abs(period);
    period = period(:);
    period2 = unique(period);
    num_components = numel(period);
    num_components2 = numel(period2);
    if (num_components2 ~= num_components)
        warning('matlab:lsqfourier:duplicateComponents', ...
            'Ignoring components with duplicated periods.');
        period = period2;
        num_components = num_components2;
        % don't replace by default because input periods may not be sorted.
    end
    clear num_components2 period2
    
    %% evaluate Jacobian:
    J_original = lsqfourier_jacob (time_original, period, J_original, std);
    J = J_original;  % keep J_original unmodified because it is reused.
    if any(idx_isnan),  J(idx_isnan,:) = [];  end

    %% estimate complex-valued coefficients:
    ind1st = NaN;
    switch lower(opt.method)
    case {'in-context', 'in context', 'simultaneous', 'simultaneously'}
        J2c = [real(J), -imag(J)];
        J2p = polydesign1a(time, polyd2c(degree));
        J2 = [J2c, J2p];
        param2 = J2 \ obs;
        %param2 = (J2' * J2) \ (J2' * obs);
        fit = J2 * param2;
        %param2p = param2(size(J2c,2)+1:end);
        param2c = param2(1:size(J2c,2));
        param = complex(param2c(1:end/2), param2c(end/2+1:end));
    case {'out-of-context', 'out of context', 'independent', 'independently'}
        [param, fit] = lsqfourier_independent (obs, time, degree, J);
    case {'iterated', 'iterative', 'iteratively'}
        [param, fit, ind1st] = lsqfourier_iterated (obs, time, period, ...
            degree, opt, J);
    case {'complete', 'completely'}
        opt.method = 'iterated';
        [param, fit, ~, period, degree, opt] = lsqfourier_aux (obs, time, period, ...
            degree, opt, J); %#ok<ASGLU>
        idx = (param ~= 0);
        opt.method = 'simultaneous';
        [param2, fit2, ~, period2] = lsqfourier_aux (obs, time, period(idx), ...
            degree, opt, J(:,idx));
          myassert(period2, period(idx))
        param(idx) = param2;
        fit = fit2;
    %TODO: case {'polished', 'iterated refined'}  % hint: see lsqfourier_refine
    otherwise
        error('matlab:lsqfourier:unkMethod', 'Unknown method "%s".', opt.method);
    end
    
    %% restore invalid observations:
    if any(idx_isnan)
        fit_old = fit;
        fit = NaN(numel(time_original), size(fit_old,2));
        fit(~idx_isnan,:) = fit_old;
    end
    
    %% check for aliasing:
    ind = argmax(get_power(param));
    if (num_components <= 2),  return;  end
    if (ind == num_components)
        warning('matlab:lsqfourier:aliasingHigh', ...
            ['High-frequency aliasing likely;\n'...
             'increasing the limits of the trial period/frequency recommended.'])
    %elseif (ind < 3)
    elseif (ind == 1) || (ind == 2 && isinf(period(1)))
        warning('matlab:lsqfourier:aliasingLow', ...
            ['Low-frequency aliasing detected;\n'...
             'improved detrending and/or increasing the limits of the '...
             'trial period/frequency recommended.'])
    elseif (ind ~= ind1st) && ~isnan(ind1st)
        warning('matlab:lsqfourier:aliasingMed', ...
            ['Medium-frequency aliasing likely;\n'...
             'decreasing the spacing of trial period/frequency recommended.'])
    end
end

%%
function [param, fit, trend] = lsqfourier_independent (obs, time, degree, J)
    %J = [J, J];  % DEBUG
    temp = permute(J, [1 3 2]);
    J2 = [real(temp), -imag(temp)];

    [param2, trend] = lsqfourier_independent_aux (obs, time, degree, J2);

    fit2 = frontal_mtimes(J2, param2);
    fit = permute(fit2, [1 3 2]);
    fit = add_all(fit, trend);

    param2c = complex(param2(1,:,:), param2(2,:,:));
    param = defrontal_pt(param2c);
end

%%
function [param2, trend] = lsqfourier_independent_aux (obs, time, degree, J2)
    flag = true;  % found to be faster
    %flag = false;  % EXPERIMENTAL!
    %trend = nanpolyfitval(time, obs, degree);
    [trend, ~, ~, ~] = nanpolyfitval(time, obs, degree);  % allow time centering & scaling
    obs = obs - trend;
    J2t = frontal_transpose(J2);
    N = frontal_mtimes(J2t, J2);
    u = frontal_mtimes(J2t, obs, flag);
    C = frontal_inv_2by2_symm(N);
    param2 = frontal_mtimes(C, u);
end

%%
function [param, fit, ind1st] = lsqfourier_iterated (obs, time, period, ...
degree, opt, J) %#ok<INUSL>
    [num_obs, num_components] = size(J);
    %J = [J, J];  % DEBUG
    temp = permute(J, [1 3 2]);
    J2 = [real(temp), -imag(temp)];

    %if (opt.tol < 0),  opt.tol = abs(opt.tol);  else  opt.tol = opt.tol*(obs'*obs);  end  % WRONG!
    if (opt.tol < 0),  tol = abs(opt.tol);  else  tol = opt.tol*(obs'*obs);  end
    param2 = zeros(2,1,num_components);
    fit2 = zeros(num_obs,1,num_components);
    residi = obs;
    trend_old = zeros(num_obs,1);
    for i=1:min(num_components, opt.max_num_components)
        obsi = residi + trend_old;
        [param2i, trend] = lsqfourier_independent_aux (obsi, time, degree, J2);        
        residi = obsi - trend;  % residi = residi - (trend - trend_old);
      
        power2i = param2i(1,:,:).^2 + param2i(2,:,:).^2;  % = sum(parami.^2,1);
        j = argmax(power2i, [], 3);
          if (i == 1),  ind1st = j;  end
        param2ij = param2i(:,:,j);
        fit2ij = J2(:,:,j) * param2ij;

        param2(:,:,j) = param2(:,:,j) + param2ij;  % real and imaginary.
        fit2(:,:,j) = fit2(:,:,j) + fit2ij;

        residi = residi - fit2ij;
        if ((residi'*residi) <= tol),  continue;  end
    end

    param2c = complex(param2(1,:,:), param2(2,:,:));
    param = defrontal_pt(param2c);

    fit = permute(fit2, [1 3 2]);
    fit = add_all(fit, trend);
end

%%
function J = lsqfourier_jacob (time, period, J, std)
    if (nargin < 3),  J = [];  end
    if (nargin < 4),  std = [];  end
    
    %time_mat = repmat(time, [min(1,num_obs), num_components]);
    %period_mat = repmat(period', [num_obs, min(1,num_components)]);
    %arg = time_mat ./ period_mat;
    if isempty(J)
        arg = bsxfun(@rdivide, time, period');
        J = exp(1i*2*pi*arg);
        clear arg
        if isempty(std),  return;  end
        assert(numel(std) == numel(time))
        J = bsxfun(@rdivide, J, std);  % = diag(1./std)*J;
        return
    end
    
    num_epochs = numel(time);
    num_tones = numel(period);
    siz = [num_epochs num_tones];
    siz2 = size(J);
    if ~isequal(siz2, siz)
        warning('MATLAB:lsqfourier:badJSize', ...
            'J matrix of wrong size (should be %dx%d, is %dx%d); ignoring it.', ...
            siz(1), siz(2), siz2(1), siz2(2));
        J = lsqfourier_jacob (time, period, [], std);
        return;
    end

    % check at least first, middle, and last elements:
    ind_time = [1; num_epochs; round(num_epochs/2)];
    ind_period = [1; num_tones; round(num_tones/2)];
    if isempty(std),  ind_std = [];  else  ind_std = ind_time;  end
    J0 = diag(lsqfourier_jacob (time(ind_time), period(ind_period), ...
      [], std(ind_std)));
    %J0 = arrayfun(@(T,P) lsqfourier_jacob(T, P, [], std(ind_std)), ...
    %  time_original(ind_time), period(ind_period));
    ind_J = sub2ind(siz, ind_time, ind_period);
    J0b = J(ind_J);
    e0 = J0b(:) - J0(:);
    if any(abs(e0) > eps())
        %e11  % DEBUG
        warning('MATLAB:lsqfourier:badJContent', ...
            'J matrix has wrong content; ignoring it.');
        J = lsqfourier_jacob (time, period, [], std);
    end
end

%%
%!test
%! % single frequency:
%! n = 10;
%! t = (1:n)';
%! freq = rand;
%! magn = rand;
%! phase = rand*360;
%! y = magn * exp(1i*phase*pi/180);
%! get_phase2 = @(x) azimuth_range_positive(get_phase(x));
%! 
%! x = magn * cos(2*pi * freq * t + phase*pi/180);
%! y2xa = @(y) abs(y) * cos(2*pi * freq * t + get_phase(y)*pi/180);
%! y2xb = @(y) real(y * exp(1i*2*pi * freq * t));
%! 
%! xa = y2xa(y);
%! xb = y2xb(y);
%! %[x, xa, xa-x]  % DEBUG
%! %[x, xb, xb-x]  % DEBUG
%!   myassert(xa, x, sqrt(eps()))
%!   myassert(xb, x, sqrt(eps()))
%! 
%! [y2, x2, J] = lsqfourier_aux (x, t, 1./freq, false, 'simultaneous');
%! %keyboard  % DEBUG
%! %[x, x2, x2-x]  % DEBUG
%!   myassert(x2, x, sqrt(eps()))
%! %[abs(y2), magn]  % DEBUG
%!   myassert(abs(y2), magn, sqrt(eps()))
%! %[get_phase2(y2), phase]  % DEBUG
%!   myassert(get_phase2(y2), phase, sqrt(eps()))
%! 
%! [y4, x4] = lsqfourier_aux (x, t, 1./freq, [], 'simultaneous');
%! %[x, x4, x4-x]  % DEBUG
%!   myassert(x4, x, sqrt(eps()))
%! % y4, y  % coefficients are not supposed to agree because of leakage.
%! 
%! [y5a, x5a] = lsqfourier_aux (x, t, NaN, [], 'simultaneous');
%! %[y5a, mean(x), mean(x)-y5a]  % DEBUG
%!   myassert(y5a, mean(x), sqrt(eps()))
%! 
%! [y5b, x5b] = lsqfourier_aux (x, t, NaN, [], 'independent');
%! %[y5b, mean(x), mean(x)-y5b]  % DEBUG
%!   myassert(isempty(y5b))
%! 
%! [y6, x6] = lsqfourier_aux (x, t, 1./freq, NaN, 'independent');
%! %keyboard
%! %[x, x6, x6-x]  % DEBUG
%!   myassert(x6, x, sqrt(eps()))
%! %[y, y6, y6-y]  % DEBUG
%! %[abs(y6), magn]  % DEBUG
%!   myassert(abs(y6), magn, sqrt(eps()))
%! %[get_phase2(y6), phase]  % DEBUG
%!   myassert(get_phase2(y6), phase, sqrt(eps()))
%! 
%! m = 3;
%! s0 = warning('off', 'matlab:lsqfourier:duplicateComponents');
%! s1 = struct();  [s1.msg, s1.id] = lastwarn('');
%! [y7, x7] = lsqfourier_aux (x(:,1), t, ones(m,1)./freq, NaN, 'independent');
%! s2 = struct();  [s2.msg, s2.id] = lastwarn(s1.msg, s1.id);
%! warning(s0)
%! assert(strcmp(s2.id, 'matlab:lsqfourier:duplicateComponents'))
%! 
%! %[x, x7, x7-x]  % DEBUG
%!   myassert(x7, x, sqrt(eps()))
%! %[y, y7, y7-y]  % DEBUG
%! %[abs(y7), magn]  % DEBUG
%!   myassert(abs(y7), magn, sqrt(eps()))
%! %[get_phase2(y7), phase]  % DEBUG
%!   myassert(get_phase2(y7), phase, sqrt(eps()))

%!test
%! % multiple distinct frequencies:
%! n = 10;
%! t = (1:n)';
%! freq = rand(2,1);
%! phase = rand(2,1)*360;
%! magn = rand(2,1);
%! magn(:) = mean(magn);  % make it more comparable
%! y = magn .* exp(1i*phase*pi/180);
%! get_phase2 = @(x) azimuth_range_positive(get_phase(x));
%! 
%! x = magn(1) * cos(2*pi * freq(1) * t + phase(1)*pi/180) ...
%!   + magn(2) * cos(2*pi * freq(2) * t + phase(2)*pi/180);
%! y2xa = @(y) abs(y(1)) * cos(2*pi * freq(1) * t + get_phase(y(1))*pi/180) ... 
%!           + abs(y(2)) * cos(2*pi * freq(2) * t + get_phase(y(2))*pi/180);
%! y2xb = @(y) real(y(1) * exp(1i*2*pi * freq(1) * t)) ...
%!           + real(y(2) * exp(1i*2*pi * freq(2) * t));
%! 
%! xa = y2xa(y);
%! xb = y2xb(y);
%! %[x, xa, xa-x]  % DEBUG
%! %[x, xb, xb-x]  % DEBUG
%!   myassert(xa, x, sqrt(eps()))
%!   myassert(xb, x, sqrt(eps()))
%! 
%! [y2, x2, J] = lsqfourier_aux (x, t, 1./freq, NaN, 'simultaneous');
%! %[x, x2, x2-x]  % DEBUG
%!   myassert(x2, x, sqrt(eps()))
%! %[abs(y2), magn]  % DEBUG
%!   myassert(abs(y2), magn, sqrt(eps()))
%! %[get_phase2(y2), phase]  % DEBUG
%!   myassert(get_phase2(y2), phase, sqrt(eps()))
%! 
%! [y4, x4] = lsqfourier_aux (x, t, 1./freq, true, 'simultaneous');
%!   %figure, hold on, plot(t, x4, 'o-r'), plot(t, x, '.-b')
%! %[x, x4, x4-x]  % DEBUG
%!   myassert(x4, x, sqrt(eps()))
%! % y4, y  % coefficients are not supposed to agree because of leakage.
%! 
%! %keyboard
%! [y6, x6] = lsqfourier_aux (x, t, 1./freq, NaN, 'independent');
%!   %figure, hold on, plot(t, x6, 'o-r'), plot(t, x, '.-b')
%! %[x, x6, x6-x]  % DEBUG
%!   %myassert(x6, x, sqrt(eps()))
%! %[y, y6, y6-y]  % DEBUG
%! %[abs(y6), magn]  % DEBUG
%!   %myassert(abs(y6), magn, sqrt(eps()))
%! %[get_phase2(y6), phase]  % DEBUG
%!   %myassert(get_phase2(y6), phase, sqrt(eps()))
%! 
%! [y7, x7] = lsqfourier_aux (x, t, 1./freq, NaN, 'iterated');
%! x7(:,end+1) = sum(x7,2);
%!   %figure, hold on, plot(t, x7, 'o-r'), plot(t, x, '.-b')
%! 
%! [y8a, x8a] = lsqfourier_aux (x, t, 1./freq, NaN, {'iterated', Inf, 1});
%! [y8b, x8b] = lsqfourier_aux (x, t, 1./freq, NaN, {'complete', Inf, 1});
%! %keyboard

%!test
%! % two signals of the same frequency but different phase 
%! % add up in the complex domain.
%! n = 10;
%! t = (1:n)';
%! freq = rand(2,1);
%! phase = rand(2,1)*360;
%! magn = rand(2,1);
%! magn(:) = mean(magn);  % make it more comparable
%! freq(:) = mean(freq);
%! y = magn .* exp(1i*phase*pi/180);
%! get_phase2 = @(x) azimuth_range_positive(get_phase(x));
%! 
%! x = magn(1) * cos(2*pi * freq(1) * t + phase(1)*pi/180) ...
%!   + magn(2) * cos(2*pi * freq(2) * t + phase(2)*pi/180);
%! y2xa = @(y) abs(y(1)) * cos(2*pi * freq(1) * t + get_phase(y(1))*pi/180) ... 
%!           + abs(y(2)) * cos(2*pi * freq(2) * t + get_phase(y(2))*pi/180);
%! y2xb = @(y) real(y(1) * exp(1i*2*pi * freq(1) * t)) ...
%!           + real(y(2) * exp(1i*2*pi * freq(2) * t));
%! 
%! xa = y2xa(y);
%! xb = y2xb(y);
%! %[x, xa, xa-x]  % DEBUG
%! %[x, xb, xb-x]  % DEBUG
%!   myassert(xa, x, sqrt(eps()))
%!   myassert(xb, x, sqrt(eps()))
%! 
%! s = warning('off', 'matlab:lsqfourier:duplicateComponents');
%! [y6, x6] = lsqfourier_aux (x, t, 1./freq, NaN, 'independent');
%! warning(s)
%!   %figure, hold on, plot(t, x6, 'o-r'), plot(t, x, '.-b')
%! %[x, x6, x6-x]  % DEBUG
%!   myassert(x6, x, sqrt(eps()))
%! %[y, y6, y6-y]  % DEBUG
%!   myassert(y6, sum(y), sqrt(eps()))
%! 
%! s = warning('off', 'matlab:lsqfourier:duplicateComponents');
%! [y7, x7] = lsqfourier_aux (x, t, 1./freq, NaN, 'iterated');
%! warning(s)
%!   %figure, hold on, plot(t, x7, 'o-r'), plot(t, x, '.-b')
%! %[x, x7, x7-x]  % DEBUG
%!   myassert(x7, x, sqrt(eps()))
%! %[y, y7, y7-y]  % DEBUG
%!   myassert(y7, sum(y), sqrt(eps()))
