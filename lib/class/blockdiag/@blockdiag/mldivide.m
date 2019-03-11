function x = mldivide (A, b)
    myassert(isblockdiag(A) && ~isblockdiag(b))
    myassert(size(A,2) == size(b,1));
    D = diag(cell(A));
    [ms, ns] = sizes(D);
    b2 = mat2cell(b, ms);
    x = cellfun(@mldivide, D, b2, 'UniformOutput',false);
    x = cell2mat(x);
end

%!shared
%! D = {};
%! N = 1 + ceil(10*rand);
%! for i=1:N
%!     %m = ceil(10*rand);
%!     n = ceil(10*rand);
%!     D{i} = gallery('minij', n);
%! end
%! A = blockdiag(D);

%!test
%! % mldivide()
%! b = rand(size(A,1), ceil(10*rand));
%! x = unblockdiag(A) \ b;
%! x2 = A \ b;
%! max(abs(x2(:) - x(:)))
%! myassert(x2, x, -10*eps);

