function varargout = interp1nonunique (x, y, varargin)
    assert(isvector(x))
    %if issorted(x)  % WRONG!
    if issorted(x) && is_unique(x)
        [varargout{1:nargout}] = interp1 (x, y, varargin{:});
        return;
    end
    [x, ind] = unique(x);
    if isvector(y),  y = y(ind);  else  y = y(ind,:);  end
    [varargout{1:nargout}] = interp1 (x, y, varargin{:});
end


