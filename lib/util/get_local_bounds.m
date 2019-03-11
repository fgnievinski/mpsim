% lower and upper bounds for local convergency of each parameter
% around its true value, keeping other parameters fixed to 
% their true value.
%
% here we rely mostly on fzerod, which may fail.
%
% the lower (upper) bound on the approximate value for a param 
% is defined by as the maximum (minimum) left (right) root of 
% the partial derivative of f w.r.t. each parameter, 
% in the neighborhood of the true values of the parameters.
function [l2, u2, l, u] = get_local_bounds (df_dx, param_true, obs_true, const)
    num_params = length(param_true);
    num_obs    = length(obs_true);
    num_eqs    = size(df_dx(param_true, obs_true, const), 1);

    get_el = @(M, i, j) subsref(M, substruct('()', {i, j}));

    %% each param has a diff bound for each eq. and for each param:
    l = zeros(num_eqs, num_params, num_params);
    u = zeros(num_eqs, num_params, num_params);
    for i=1:num_eqs
    for j=1:num_params
    for k=1:num_params
        g = @(xx) get_el(...
                df_dx(...
                    [param_true(1:k-1);xx;param_true(k+1:end)], ...
                    obs_true, const), ...
                i, j);
        l(i,j,k) = fzerod(g, param_true(k), 'lower', 50);
        u(i,j,k) = fzerod(g, param_true(k), 'upper', 50);
    end
    end
    end
    l(isnan(l)) = -Inf;
    u(isnan(u)) = +Inf;

    %% since we're interested in a single value for each parameter
    % for all eq., we use the one which satisfies them all:
    l2 = squeeze(max(max(l, [], 1), [], 2));
    u2 = squeeze(min(min(u, [], 1), [], 2));
end

%!test
%! F = @(x,c) x(1) + x(2)*c + x(3)*sin(x(4)*c) + x(5)*cos(x(6)*c);
%! f = @(x,l,c) F(x,c) - l;
%! df_dx = @(x, l, c) [...
%!     ones(size(c)), ...
%!     c, ...
%!     sin(x(4).*c), ...
%!     x(3).*cos(x(4).*c).*c, ...
%!     cos(x(6).*c), ...
%!     -x(5).*sin(x(6).*c).*c ...
%! ];
%! df_dl = @(x,l,c) -eye(length(l));
%! 
%! x = rand(6, 1);
%! n = 6 + 1 + round(10*rand);
%! c = rand(n,1).*10;
%! c(1:ceil(end/2)) = -1*c(1:ceil(end/2));
%! l = F(x,c);
%! myassert(f(x,l,c), zeros(size(l)))
%! 
%! % check analytical jacobian against numerical jacobian:
%! df_dx2 = diff_func2(@(x2) f(x2,l,c), x);
%!   %df_dx(x,l,c) - df_dx2  % DEBUG
%!   myassert(df_dx(x,l,c), df_dx2, -sqrt(eps))
%! df_dl2 = diff_func2(@(l2) f(x,l2(:),c), l);
%!   %df_dl(x,l,c) - df_dl2  % DEBUG
%!   myassert(df_dl(x,l,c), df_dl2, -sqrt(eps))
%! 
%! param_true = x;
%! obs_true = l;
%! const = c;
%! 
%! num_params = length(param_true);
%! num_obs = length(obs_true);
%! num_eqs = length(f(param_true,obs_true,const));
%! 
%! 
%! [l, u] = get_local_bounds (df_dx, param_true, obs_true, const)
%! l(l==-Inf) = -nthroot(realmax,3);
%! u(u==+Inf) = +nthroot(realmax,3);
%! myassert(~any(isinf(u - l)))
%! 
%! for k=1:num_params
%!     [k, l(k), u(k)]  % DEBUG
%!     param_approx = param_true;
%!     param_approx(k) = randint(l(k), u(k))
%! 
%!     df_dx_true   = df_dx(param_true,   obs_true, const);
%!     df_dx_approx = df_dx(param_approx, obs_true, const);
%!     %[sign(df_dx_true), NaN(num_eqs,1), ...
%!     % sign(df_dx_approx), NaN(num_eqs,1), ...
%!     % sign(df_dx_true)-sign(df_dx_approx)]
%!     %pause  % DEBUG
%!     myassert(sign(df_dx_true), sign(df_dx_approx))
%! end

