function yi = naninterp1 (x, y, xi, varargin)
    if isvector(y)
       x = x(:);
       y = y(:);
       idx = (isnan(x) | isnan(y));
       x(idx) = [];
       y(idx) = [];
    else
       x = x(:);
       assert(size(y,1) == numel(x))
       idx = (isnan(x) | any(isnan(y),2));
       x(idx) = [];
       y(idx,:) = [];       
    end
    if (numel(x) < 2)
      yi = NaN(size(xi));
      return;
    end
    yi = interp1 (x, y, xi, varargin{:});
end
