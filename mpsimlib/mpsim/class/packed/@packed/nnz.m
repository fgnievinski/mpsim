function answer = nnz (A)
    switch nargin
    case 0
        error('packed:nnz:notEnoughInputs', ...
        'Not enough input parameters.');
    case 1
        nnz_data = nnz(A.data);
        if istri_type (A)
            answer = nnz_data;
        elseif issym_type(A)
            s.type = '()';
            s.subs = {diag(true(size(A, 1), 1))};
            nnz_diag = nnz(subsref(A, s));
            
            answer = 2 * nnz_data - nnz_diag;
        else
            answer = 0;
        end
    otherwise
        error('packed:nnz:tooManyInputs', ...
        'Too many input parameters.');
    end
end

%!test
%! A = packed(eye(3));
%! myassert(ispacked(A));
%! myassert (nnz(A), 3);

%!test
%! A = packed([1 2 3; 0 1 2; 0 0 1]);
%! myassert(ispacked(A));
%! myassert (nnz(A), 6);

%!test
%! A = packed([1 2 3; 0 1 2; 0 0 1]');
%! myassert(ispacked(A));
%! myassert (nnz(A), 6);

%!test
%! A = packed([1 2 0; 2 1 2; 0 2 1]);
%! myassert(ispacked(A));
%! myassert (nnz(A), 7);

%!test
%! A = packed([1 2; 0 1]);
%! myassert(ispacked(A));
%! myassert (nnz(A), 3);

%! A = packed([]);
%! myassert(ispacked(A));
%! myassert (nnz(A), 0);

%!test
%! A = packed;
%! myassert(ispacked(A));
%! myassert (nnz(A), 0);

%!error
%! A = packed;
%! myassert(ispacked(A));
%! nnz(A, 1, 2, 3);

%!error
%! A = packed;
%! myassert(ispacked(A));
%! myassert(nnz(A, 10), 1);

