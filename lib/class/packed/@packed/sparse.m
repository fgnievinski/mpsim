function answer = sparse (A)
    if isempty(A)
        idx = [];
        data = [];
    elseif istriu(A)
        idx = triu(true(order(A)));
    elseif istril(A)
        idx = tril(true(order(A)));
    elseif issym(A)
        idx = true(order(A));
    else
        error('packed:sparse:unknownType', '');
    end

    S.type = '()';  S.subs = {idx};
    data = subsref(A, S);
        clear S
    [i, j] = find(idx);
        clear idx
    answer = sparse (i, j, data, order(A), order(A));
end

%!test
%! n = 10;
%! for i=1:5
%!     switch i
%!     case 1
%!         A_full = eye(n);
%!     case 2
%!         temp = rand(n);
%!         A_full = triu(temp);
%!     case 3
%!         temp = rand(n);
%!         A_full = tril(temp);
%!     case 4
%!         A_full = randsym(n);
%!         myassert (issym(A_full));
%!     case 5
%!         A_full = [];
%!     end
%! 
%!     A_packed = packed(A_full);
%!     myassert (ispacked(A_packed));
%!     
%!     A_sparse = sparse (A_full);
%!     myassert (issparse(A_sparse));
%! 
%!     A_sparse2 = sparse (A_packed);
%!     myassert (issparse(A_sparse2));
%! 
%!     myassert (A_sparse2, A_sparse);
%! 
%!     clear A_full
%! end

