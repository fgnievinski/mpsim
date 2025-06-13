function answer = end (A, k, n)
    switch n
    case 1
        answer = order(A)^2;
    case 2
        answer = order(A);
    otherwise
        answer = 1;
    end        
end

%!test
%! A_full = [...
%!     1 2 4 
%!     0 3 5 
%!     0 0 6
%! ];
%! A = packed(A_full, 'tri', 'u');
%! myassert(ispacked(A));
%! myassert(A(end), 6);
%! myassert(A(end,1), 0);
%! myassert(A(1,end), 4);

