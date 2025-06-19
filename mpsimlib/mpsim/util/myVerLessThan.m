function varargout = myVerLessThan (varargin)
    persistent varargins varargouts nargouts
    if isempty(varargins),   varargins  = {};  end
    if isempty(varargouts),  varargouts = {};  end
    max_recall = 10;

    thevarargin = varargin;
    thenargout = nargout;
    f = @(i) (nargouts(i) == thenargout) && isequaln(varargins{i}, thevarargin);
    %f = @(i) (nargouts(i) == nargout) && isequaln(varargins{i}, varargin);  % WRONG!
    idx = arrayfun(f, 1:numel(nargouts));
    
    if any(idx)
        assert(sum(idx) == 1)
        varargout = varargouts{idx};
    else
        [varargout{1:nargout}] = verLessThan(varargin{:});
        if (numel(varargouts) > max_recall),  return;  end
        varargins{end+1} = varargin;
        varargouts{end+1} = varargout;
        nargouts(end+1) = nargout;
    end
end
