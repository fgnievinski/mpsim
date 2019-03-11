function answer = istril (A)
    error(nargchk(1, 1, nargin, 'struct'));
    error(nargoutchk(0, 1, nargout, 'struct'));

    % degenerate shape:
    if ( isempty(A) || isscalar(A) || ~issquare(A) )
        answer = false;
        return;
    end
    
    % check if upper part is all zeros:
    idx = triu(true(size(A)), +1);
    if (nnz(A(idx)) == 0)
    %if any(A(idx))  % should not be used because any() ignores NaNs.
        answer = true;
    else
        answer = false;
    end
end

%!test
%! % istril ()
%! do_test_blank_diag_tri_sym;

