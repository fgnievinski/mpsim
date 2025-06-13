function varargout = std_transform2 (trans_inv, trans_fwd, mean, varargin)
    [varargout{1:nargout}] = std_transform (trans_fwd, mean, varargin{:});
    if (nargout < 2)
        std2 = varargout{1};
        std2l = std2;
        std2u = std2;
    else
        [std2l, std2u] = varargout{:};
    end
    
    mean2 = trans_fwd(mean);
    lower2 = mean2 - std2l;
    upper2 = mean2 + std2u;
    lower = trans_inv(lower2);
    upper = trans_inv(upper2);
    stdu = upper - mean;
    stdl =         mean - lower;
    std = max(abs(stdl), abs(stdu));
    
    if (nargout < 2)
        varargout = {std};
    else
        varargout = {stdl, stdu};
    end
end
