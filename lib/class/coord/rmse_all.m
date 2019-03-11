function y = rmse_all (x)
    [m, n] = size(x);
    y = zeros(1,n);
    for j=1:n
        y(1,j) = norm(x(:,j)) / sqrt(m);
    end

end

%!test
%! x = [5 4 3];
%! answer = [5 4 3];
%! %rmse_all(x)  % DEBUG
%! myassert ( rmse_all(x), answer);

%!test
%! x = [5 4 3]';
%! answer = sqrt(5*5+4*4+3*3) / sqrt(3);
%! %rmse_all(x)  % DEBUG
%! myassert ( rmse_all(x), answer);

