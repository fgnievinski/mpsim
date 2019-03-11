function C = frontal_inv (A)
    [m,n,o] = size(A);
    if (m ~= n)
        error('MATLAB:frontal:inv:square', ...
        'Frontal pages must be square.');
    end
    C = zeros(m,n,o);
    for k=1:o
        C(:,:,k) = inv(A(:,:,k));
    end
end

%!test
%! % frontal_inv
%! warning('off', 'test:noFuncCall');

%!test
%! lasterror('reset')

%!error
%! frontal_inv(zeros(3,2));

%!test
%! s = lasterror;
%! myassert(s.identifier, 'MATLAB:frontal:inv:square')

%!test
%! warning('on', 'test:noFuncCall');


%!shared
%! c = round(10*rand);
%! A = rand(c, c);

%!test
%! % frontal matrices with only one page 
%! % can be treated as 2d matrices.
%! C = frontal_inv(A);
%! C2 = inv(A);
%! myassert (C, C2);

%!test
%! o = ceil(10*rand);
%! C = frontal_inv(repmat(A, [1,1,o]));
%! C2 = repmat(inv(A), [1,1,o]);
%! myassert (C, C2);

