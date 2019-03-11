function dy_dx = logitinv_deriv (x)
    y = logitinv(x);
    dy_dx = exp(-x).*y.^2;
end

%!test
%! x = linspace(-10, +10)';
%! y = logitinv(x);
%! dy_dx = exp(-x).*y.^2;
%! dy_dx_num = gradient(y, x);
%! figure
%! hold on
%! plot(x, dy_dx, '.-k')
%! plot(x, dy_dx_num, 'or')
