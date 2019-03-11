function answer = isblank (A)
    error(nargchk(1, 1, nargin, 'struct'));
    error(nargoutchk(0, 1, nargout, 'struct'));

    % degenerate shape:
    if ( isempty(A) || isscalar(A) || ~issquare(A) )
        answer = false;
        return;
    end
    
    answer = (nnz(A) == 0);
    %answer = ~any(A(:));  % should not be used because any() ignores NaNs.    
end

%!test
%! % isblank ()
%! do_test_blank_diag_tri_sym;

