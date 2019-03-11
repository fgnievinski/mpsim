function answer = issym (A, tol)
    error(nargchk(1, 2, nargin, 'struct'));
    error(nargoutchk(0, 1, nargout, 'struct'));
    if (nargin < 2),  tol = [];  end

    % degenerate shape:
    if ( isempty(A) || isscalar(A) || ~issquare(A) )
        answer = false;
        return;
    end
    
    % not symmetric?
    % (use .' instead of '):
    if  (isempty(tol) && ~isequaln(A, A.')) ...
    || (~isempty(tol) && any(any( abs(A - A.') > tol )))
        answer = false;        
        return;
    end

    answer = true;
end

%!test
%! A = [1, 1+i; 1-i, 1];
%! myassert (~issym(A));

%!test
%! A = [1, 1+i; 1+i, 1];
%! myassert (issym(A));

%!test
%! % issym ()
%! do_test_blank_diag_tri_sym;

%!test
%! A = [1 0; eps 1];
%! %issym(A)
%! %issym(A, eps)
%! myassert(~issym(A));
%! myassert(issym(A, eps));
