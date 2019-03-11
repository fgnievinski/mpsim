function C = frontal_mtimes2 (varargin)
    A = varargin{1};
    if (nargin < 2)
        error('frontal_mtimes2:tooFew', 'Too few input arguments.');
    elseif (nargin == 2)
        B = varargin{2};
    else  % (nargin > 2)
        B = frontal_mtimes2(varargin{2:end});
    end
    C = frontal_mtimes(A, B);
end

%!test
%! A1 = rand;
%! A2 = rand;
%! A3 = rand;
%! A4a = A1 * A2 * A3;
%! A4b = frontal_mtimes2(A1, A2, A3);
%! %A4a, A4b, A4b-A4a  % DEBUG
%! myassert(A4b, A4a, -eps())

