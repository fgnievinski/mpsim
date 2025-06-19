function C = plus(A, B)
    if issparse(B)
        check_op(A, B, 'plus', 'MATLAB');
        C = zeros(size(A), 'single');
        ind = find(B);  C(ind) = single(full(B(ind)));
        % avoid making _all_ of B full.
        C = C + A;
    elseif issparse(A)
        C = B + A;
        return;
    else
        C = builtin('plus', A, B);
    end
end

%!test
%! % plus ()
%! %n = 1;
%! n = round(10*rand);
%! A = single(rand(n));
%! B = rand * speye(n);
%! 
%! C = A + B;
%! C2 = A + single(full(B));
%! %C, C2  % DEBUG
%! myassert(C, C2);
%! %disp('hw!')
%! 
%! C = B + A;
%! C2 = single(full(B)) + A;
%! myassert(C, C2);
%! %disp('hw!')
%! 
%! C = A + A;
%! C2 = single(double(A) + double(A));
%! myassert(C, C2)
%! %disp('hw!')

%!test
%! % plus()
%! lasterror('reset');

%!error
%! plus(single(eye(2)), speye(3))

%!test
%! % plus()
%! s = lasterror();
%! %s.identifier  % DEBUG
%! myassert(s.identifier, 'MATLAB:dimagree')

