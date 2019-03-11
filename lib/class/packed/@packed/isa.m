function answer = isa (obj, class_name)
    if ~ischar(class_name)
        error('packed:isa:nonCharClassName', ...
        'Second parameter (class name) should be a string.');
    end
    answer = strcmp(class_name, 'packed') | isa(obj.data, class_name);
end

%!test
%! A = packed(eye(2,2));
%! myassert (isa(A, 'packed'));
%! myassert (isa(A, 'double'));

%!test
%! A = packed(cast(eye(2,2), 'single'));
%! myassert (isa(A, 'packed'));
%! myassert (isa(A, 'single'));

%!test
%! A = packed(cast(eye(2,2), 'uint8'));
%! myassert (isa(A, 'packed'));
%! myassert (isa(A, 'uint8'));

%!error
%! isa(packed, 1);

