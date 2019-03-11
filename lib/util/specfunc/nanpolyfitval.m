function [y2, p, varargout] = nanpolyfitval (x, y, n, x2)
    %if (nargin < 4) || isempty(x2),  x2 = x;  end  % WRONG!
    if (nargin < 4),  x2 = x;  end
    [p, varargout{1:nargout-2}] = nanpolyfit(x, y, n);
    if isempty(p)
        assert(isnan(n))
        %y2 = y;  % WRONG!
        y2 = zeros(size(y));
    else
        y2 = polyval(p, x2, varargout{:});
    end
end

