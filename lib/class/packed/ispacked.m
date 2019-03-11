function answer = ispacked (in)
    answer = isa(in, 'packed');
end

%!test
%! A = packed;
%! myassert (ispacked(A));
%! 
%! A = 0;
%! myassert (~ispacked(A));
%! 
%! A = sparse(0);
%! myassert (~ispacked(A));
