function varargout = chol (A, uplow)
    if (nargin < 2) || isempty(uplow),  uplow = tri_uplow (A);  end
    [varargout{1:nargout}] = trifactor_pos (A, uplow);
end

%!test

