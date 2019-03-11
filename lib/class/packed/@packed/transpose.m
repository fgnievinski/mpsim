function answer = transpose (A)
    if isempty(A)
        answer = A;
    elseif issym_type (A)
        answer = A;
    elseif istri_type (A)
        temp = transpose(full(A));
        if isup(A)
            new_uplow = 'l';
        elseif islow(A)
            new_uplow = 'u';
        end
        answer = packed(temp, 'tri', new_uplow);
    end
end

%!test
%! myassert (isempty(transpose(packed([]))));
%! myassert (isempty(transpose([])));

%!test
%! for type = {'tri', 'sym'},  type = type{:};
%! for uplow = {'u', 'l'},  uplow = uplow{:};
%!     while true
%!         n = round(10*rand);
%!         if (n > 2),  break;  end
%!     end
%! 
%!     if strcmp(type, 'sym')
%!         A_full = randsym(n);
%!     elseif strcmp(type, 'tri') && strcmp(uplow, 'u')
%!         A_full = triu(rand(n));
%!     elseif strcmp(type, 'tri') && strcmp(uplow, 'l')
%!         A_full = tril(rand(n));
%!     end
%! 
%!     A = packed(A_full, type, uplow);
%!     myassert (ispacked(A));
%! 
%!     myassert (ispacked(transpose(A)));
%!     myassert (transpose(A), transpose(A_full));
%! end

%!test
%! n = 4;
%! A = packed(complex(rand(n)), 'tri', 'u');
%!     myassert(~isreal(A));
%! A_full = full(A);
%!     myassert(~isreal(A_full));
%! B = transpose(A);
%! B_full = transpose(A_full);
%! myassert (B, B_full);
%! myassert(~isreal(B));
%! myassert(~isreal(B_full));

