function answer = exp (x)
    if isempty(x)
        answer = packed([]);
        return;
    end

    % special case for triangular matrices
    % because exp(0) ~= 0:
    if istri_type (x)
        answer = exp(full(x));
        return;
    end
        
    answer = x;
    answer.data = exp(x.data);
end

%!test
%! myassert(isempty( exp(packed([])) ));

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
%!     myassert (exp(A), exp(A_full));
%!        
%! end
%! end

