function varargout = frontal_func (func, A, varargin)
    [m,n,o] = size(A);
    [varargout{1:nargout}] = func(zeros(m,n), varargin{:});
    varargout = cellfun2(@(in) repmat(in, [1 1 o]), varargout);
    for k=1:o
        [varargouti{1:nargout}] = func(A(:,:,k), varargin{:});
        setk = @(in, in2) setel(in, {':',':',k}, in2);
        varargout = cellfun2(setk, varargout, varargouti);
    end
end
