function s = nanrslope (x, y, n_max)
%NANRSLOPE: Robust slope estimator (ignoring NaNs).

    if (nargin < 3) || isempty(n_max),  n_max = Inf;  end
    
    idx = isnan(x) | isnan(y);
    x(idx) = [];
    y(idx) = [];
    
    n = numel(x);
    if (n == 0)
        s = NaN;
        return;
    end
    if (n > n_max)
        %ind_max = randind(n_max);  % WRONG!
        ind = randind(n);
        ind_max = ind(1:n_max);
        x = x(ind_max);
        y = y(ind_max);
    end
    
    s = Theil_Sen_Regress (x, y);
end
