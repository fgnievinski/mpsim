function cov = frontal_variance (var)
    [m,n] = size(var);
    myassert (n == 3);

    cov = zeros(3,3,m);

    cov(1,1,:) = var(:,1);
    cov(2,2,:) = var(:,2);
    cov(3,3,:) = var(:,3);
end

%!test
%! n = ceil(10*rand);
%! var = ones(n,3);
%! cov = frontal_variance (var);
%! myassert (size(cov,1), 3);
%! myassert (size(cov,2), 3);
%! myassert (size(cov,3), n);
%! var2 = [...
%!     reshape(cov(1,1,:), n, 1), ...
%!     reshape(cov(2,2,:), n, 1), ...
%!     reshape(cov(3,3,:), n, 1), ...
%! ];
%! myassert (var2, var);

