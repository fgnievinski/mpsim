function [yi, varargout] = interp1nonunique (x, y, xi, varargin)
    assert(isvector(x))
    %if issorted(x)  % WRONG!
    if (numel(x) < 2)
      yi = NaN(size(xi));
      return;
    end
    if issorted(x) && is_unique(x)
        [yi, varargout{1:nargout-1}] = interp1 (x, y, xi, varargin{:});
        return;
    end
    [x, ind] = unique(x);
    if isvector(y),  y = y(ind);  else  y = y(ind,:);  end
    [yi, varargout{1:nargout-1}] = interp1 (x, y, xi, varargin{:});
end


