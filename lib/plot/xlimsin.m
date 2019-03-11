function varargout = xlimsin (lim, fncs)
    if (nargin < 2) || isempty(fncs),  fncs = {@sind @asind};  end
    if (nargin < 1)
        lim = xlim ();
        lim = fncs{2}(lim);
        varargout = {lim};
        %varargout(nargout+1:end) = [];  % xlim() always returns output.
        return
    end
    if ~ischar(lim) ...  % e.g., lim = 'auto'
    && ~isscalar(lim)    % e.g., lim = gca()
        lim = fncs{1}(lim);
        lim = sort(lim);
    end
    [varargout{1:nargout}] = xlim(lim);
end