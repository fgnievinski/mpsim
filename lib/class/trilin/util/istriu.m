function answer = istriu (A)
    error(nargchk(1, 1, nargin, 'struct'));
    error(nargoutchk(0, 1, nargout, 'struct'));

    % degenerate shape:
    if ( isempty(A) || isscalar(A) || ~issquare(A) )
        answer = false;
        return;
    end
    
    % check if lower part is all zeros:
    idx = tril(true(size(A)), -1);
    if (nnz(A(idx)) == 0)
    %if any(A(idx))  % should not be used because any() ignores NaNs.
        answer = true;
    else
        answer = false;
    end
end

%!test
%! % istriu ()
%! do_test_blank_diag_tri_sym;

