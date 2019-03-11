function c = wrap_ind (a, b)
    %c = mod(a-1, b-1)+1;  % WRONG!
    c = mod(a, b);  c(c==0) = b;
end

%!test
%! a = 1:5;
%! b = 3;
%! c = [1 2 3 1 2];
%! c2 = wrap_ind(a, b);
%! c2, c  % DEBUG
%! myassert(c2, c)

