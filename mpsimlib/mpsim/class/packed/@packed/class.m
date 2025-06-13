function answer = class (obj)
    answer = class(obj.data);
end

%!test
%! A = packed(eye(2,2));
%! myassert (class(A), 'double');

%!test
%! A = packed(cast(eye(2,2), 'single'));
%! myassert (class(A), 'single');

%!test
%! A = packed(cast(eye(2,2), 'uint8'));
%! myassert (class(A), 'uint8');

