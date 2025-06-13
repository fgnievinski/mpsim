function varargout = plotnan (arg, varargin)
    if (nargin > 1) && isvector(varargin{1}) && ~ischar(varargin{1})
        x = arg;
        y = varargin{1};
        varargin(1) = [];       
    else
        y = arg;
        n = length(y);
        %n = numel(y);  % WRONG!
        x = 1:n;
    end
    [varargout{1:nargout}] = plotnanaux (x, y, varargin{:});
end

function varargout = plotnanaux (x, y, varargin)
    idx = ~isnan(x) & ~isnan(y);
    [varargout{1:nargout}] = plot(x(idx), y(idx), varargin{:});
end
