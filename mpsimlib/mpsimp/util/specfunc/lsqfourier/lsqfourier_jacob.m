function J = lsqfourier_jacob (time, period, J, std, check_jacob)
%LSQFOURIER_JACOB: Jacobian matrix for LSSA.

    if (nargin < 3),  J = [];  end
    if (nargin < 4),  std = [];  end
    if (nargin < 5) || isempty(check_jacob),  check_jacob = true;  end    
    
    %time_mat = repmat(time, [min(1,num_obs), num_components]);
    %period_mat = repmat(period', [num_obs, min(1,num_components)]);
    %arg = time_mat ./ period_mat;
    if isempty(J)
        cycles = bsxfun(@rdivide, colvec(time), rowvec(period));
        J = exp(1i*2*pi*cycles);
        clear cycles
        if isempty(std),  return;  end
        assert(numel(std) == numel(time))
        J = bsxfun(@rdivide, J, colvec(std));  % = diag(1./std)*J;
        return
    end
    
    if ~check_jacob,  return;  end
    
    % check if size matches:
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
    if isempty(std),  ind_std = [];  else,  ind_std = ind_time;  end
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

