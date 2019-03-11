function A = makeitsymm (A, uplow)
    if (nargin < 2),  uplow = 'upper';  end
    myassert( any(strcmp(uplow, {'upper','lower'})) )
    d = diag(A);
    switch uplow
    case 'upper'
        A = triu(A, +1);
    case 'lower'
        A = tril(A, -1);
    end
    A = A + transpose(A);
    siz = size(A);  ind = sub2ind(siz, 1:siz(1), 1:siz(2));
    A(ind) = d;

    % I've tried to use the least amount of memory possible.
    % For example, I've avoided creating unnecessary copies of A, e.g.,
    %     A = triu(A, +1) + triu(A, +1)' + diag(diag(A));
    % I've also used the same variable name (A), throughtout the function, 
    % suggesting Matlab to write results on top of it.
    % I couldn't test this aspect of memory consumption because 
    % Matlab doesn't offer a memory profiler yet.
end

%!test
%! for i=1:10
%!     n = 1 + ceil(rand*100);
%!     myassert( issym(makeitsymm(rand(n))) );
%!     myassert( issym(makeitsymm(rand(n), 'upper')) );
%!     myassert( issym(makeitsymm(rand(n), 'lower')) );
%! end

