function out = eval_for_nonzeros (f, in, temp)
    numnonzeros = nnz(in);
    if (numnonzeros == numel(in))
        out = f(in);
    elseif (numnonzeros == 0)
        out = in;
        out(:) = temp;
        % above we keep the original data type and storage type.
    else
        idx = (in ~= 0);
        out = in;
        out(idx) = f(in(idx));
        out(~idx) = temp;
    end
end

%!test
%! in = [1 1 1 0 0 1];
%! out = eval_for_nonzeros (@(x) x, in, pi);
%! myassert(out, [1 1 1 pi pi 1])

%!test
%! in = [1 1 1 1 1 1];
%! out = eval_for_nonzeros (@(x) x, in, pi);
%! myassert(out, [1 1 1 1 1 1])

%!test
%! in = [0 0 0 0 0 0];
%! out = eval_for_nonzeros (@(x) x, in, pi);
%! myassert(out, [pi pi pi pi pi pi])

%!test
%! global i
%! i = 0;
%! function out = f (in)
%!     %global i
%!     i = i + 1;
%!     out = in;
%! end
%! eval_for_nonzeros (@f, [0 0 0], pi);
%! %i  % DEBUG
%! myassert(i == 0)  % f was not called.
%! eval_for_nonzeros (@f, [1 1 0], pi);
%! %i  % DEBUG
%! myassert(i == 1)  % f was called.

%!test
%! in = speye(2);
%! out = eval_for_nonzeros (@(x) x, in, pi);
%! myassert(issparse(out))

%!test
%! in = single(eye(2));
%! out = eval_for_nonzeros (@(x) x, in, pi);
%! myassert(isa(out, 'single'))

