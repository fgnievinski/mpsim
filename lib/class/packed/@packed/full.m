function answer = full (A)
    answer = repmat (cast(0, class(A)), size(A));
    %answer = zeros (order(A), class(A));  % doesn't work for logical or char
    myassert (isa(answer, class(A)));
    if ~isreal(A) && isreal(answer),  answer = complex(answer);  end
    
    if isempty(A)
        return;
    end
    
    if isup(A)
        idx = triu(true(order(A)));
    elseif islow(A)
        idx = tril(true(order(A)));
    end
    answer(idx) = A.data;
    myassert (isa(answer, class(A)));
    if ~isreal(A) && isreal(answer),  answer = complex(answer);  end

    if istri_type(A)
        return;
    end

    temp = answer;
    idx = diag(true(order(A), 1));  % == eye(order(A), 'logical')
    temp(idx) = cast(0, class(A));
    answer = answer + transpose(temp);
    if isa(A, 'char') || isa(A, 'logical')
        answer = cast(answer, class(A));
        % isa('a' + 'b', 'char') is false
        % isa(true + true, 'logical') is false
    end        
    myassert (isa(answer, class(A)));    
    if ~isreal(A) && isreal(answer),  answer = complex(answer);  end
end

%!test
%! for type = {'tri', 'sym'},  type = type{:};
%! for uplow = {'u', 'l'},  uplow = uplow{:};
%! for precision = {...
%!     'double', 'single', ...
%!     'int8', 'uint8',  ...
%!     'int16', 'uint16',  ...
%!     'int32', 'uint32',  ...
%!     'logical', 'char'}
%! %    'int64', 'uint64', ...  % Function 'transpose' is not defined for
%!                              % values of class 'uint64'.
%!     precision = precision{:};
%! 
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
%!     if strcmp(precision, 'logical')
%!         A_full = round(A_full);
%!     end
%!     A_full = cast(A_full, precision);
%! 
%!     A = packed(A_full, type, uplow);
%!     myassert (ispacked(A));
%!     myassert (isa(A, precision));
%! 
%!     A_full2 = full (A);
%!     myassert (A_full2, A_full);
%!     myassert (isa(A_full2, precision));
%! 
%!     clear A_full
%! end
%! end
%! end

%!test
%! % Shows why, if issym_type(A), it's bad to do
%! % answer = answer + answer.' - diag(diag(answer))
%! 
%! n = 10;
%! A_full = intmax('uint32') .* ones(n, 'uint32');
%! A = packed(A_full);
%! A_full2 = full(A);
%! myassert (A_full2, A_full);

%!test
%! % Shows why it's wrong to do answer' instead of
%! % answer.' or transpose(answer)
%! 
%! n = 10;
%! A_full = complex(ones(n), ones(n));
%! A = packed(A_full);
%! A_full2 = full(A);
%! myassert (A_full2, A_full);

%!test
%! myassert (isempty(full(packed)));

%!test
%! n = 4;
%! A = packed(complex(rand(n)), 'tri', 'u');
%!     myassert(~isreal(A));
%! A_full = full(A);
%!     myassert(~isreal(A_full));
%! myassert (A, A_full);

