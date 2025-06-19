function answer = triu (A, d)
    if (nargin < 2),  d = 0;  end
        
    if isempty(A) || isempty(d)
        answer = packed([]);
        return;
    end

    if ~ispacked(A) || ~isscalar(d)
        answer = triu(full(A), full(d));
        return;
    end

    if (d ~= 0)
        answer = packed(triu(full(A), d), 'tri', 'u');
        return;
    end
    
    if isup(A)
        answer = packed(A.data, 'tri', 'u');
        return;
    elseif islow(A)
        idx = triu(true(size(A)));
        s.subs = {idx};
        s.type = '()';        
        answer = packed(subsref(A, s), 'tri', 'u');
        return;
    end
end

%!test
%! myassert (isempty(triu(packed([]))));
%! myassert (isempty(triu([])));

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
%!     %{type, uplow}  % DEBUG
%!     temp = triu(A);
%!     myassert (ispacked(temp));
%!     myassert (temp, triu(A_full));
%!
%!     d = floor(n / 2);
%!     temp = triu(A, d);
%!     myassert (ispacked(temp));
%!     myassert (temp, triu(A_full, d));
%! end

