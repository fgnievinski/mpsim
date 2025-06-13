function varargout = propagate_cov (varargin)
    [varargout{1:nargout}] = frontal_propagate_cov (varargin{:});
end

%!test
%! [a] = propagate_cov (1, 1);
%! [a,b] = propagate_cov (1, 1);
%! test('frontal_propagate_cov')

