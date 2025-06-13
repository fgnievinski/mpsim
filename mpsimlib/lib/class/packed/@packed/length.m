function answer = length (A)
    % for some unknown reason, the builtin length() was not
    % giving the correct answer for an empty packed obj.
    switch nargin
    case 0
        error('packed:length:notEnoughInputs', ...
        'Not enough input parameters.');
    case 1
        myassert(size(A, 1), size(A, 2));
        answer = size(A, 1);
    otherwise
        error('packed:length:tooManyInputs', ...
        'Too many input parameters.');
    end
end

%!test
%! A = packed(eye(2,2));
%! myassert (length(A), 2);

%!test
%! A = packed(1);
%! myassert (length(A), 1);

%!test
%! A = packed([]);
%! myassert (length(A), 0);

%!test
%! A = packed;
%! myassert (length(A), 0);

%!error
%! A = packed;
%! length(A, 1);

