function [h1, h2] = plotcon (plotfnc, x, y, ls1, ls2, varargin)
%PLOTCON:  Plot continguous plots.

    if isempty(plotfnc),  plotfnc = @plot;  end
    if (nargin < 4) || isempty(ls1),  ls1 = '-';  end
    if (nargin < 5) || isempty(ls2),  ls2 = '.';  end

    idx = ~is_contiguous (y);
    
    washold = ishold();
    h1 = plotfnc(x, y, ls1, varargin{:});
    if ~washold,  hold('on');  end
    h2 = plotfnc(x(idx), y(idx), ls2, varargin{:});
    if ~washold,  hold('off');  end
end
