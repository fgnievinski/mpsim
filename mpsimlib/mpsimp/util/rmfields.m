function varargout = rmfields (s, f, ignore_non_existent)
    if (nargin < 3) || isempty(ignore_non_existent),  ignore_non_existent = false;  end
    if ignore_non_existent
        f(~ismember(f, fieldnames(s))) = [];
    end
    [varargout{1:nargout}] = rmfield (s, f);
end

