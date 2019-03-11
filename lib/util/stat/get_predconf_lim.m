% (this is just an interface)
function varargout = get_predconf_lim (varargin)
    [varargout{1:nargout}] = get_confpred_lim (varargin{:});
end
