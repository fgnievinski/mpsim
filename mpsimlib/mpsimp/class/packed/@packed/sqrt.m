function answer = sqrt (x)
    if isempty(x)
        answer = packed([]);
        return;
    end

    % There is no special case for triangular matrices
    % because sqrt(0) == 0;

    answer = x;
    answer.data = sqrt(x.data);
    return;
end

%!test
%! myassert(isempty( sqrt(packed([])) ));

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
%!     myassert (sqrt(A), sqrt(A_full));
%!        
%! end

