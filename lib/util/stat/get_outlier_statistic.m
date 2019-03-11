function [factor, alpha2] = get_outlier_statistic (dof, num_obs, num_params, alpha, type)
    if (nargin < 2),  num_obs = [];  end
    if (nargin < 3),  num_params = [];  end
    if (nargin < 4),  alpha = [];  end
    if (nargin < 5),  type = [];  end
    if isempty(alpha),  alpha = 5/100;  end
    [dof, num_obs, num_params] = get_outlier_argin (...
     dof, num_obs, num_params, alpha);
    if strcmpi(type, 'scheffe')
        factor = sqrt(num_params .* finv(1-alpha, num_params, dof));
        return;
    end
    alpha2 = get_outlier_alpha2 (num_obs, alpha, type);
    factor = tinv(1-(1/2).*alpha2, dof);
end

%%
function [dof, num_obs, num_params, alpha] = get_outlier_argin (dof, num_obs, num_params, alpha)
    if isempty(num_params) && isempty(num_obs),  num_params = 1;  end
    if isempty(num_params),  num_params = num_obs - dof;  end
    if isempty(num_obs),  num_obs = dof + num_params;  end
    n = max([numel(alpha), numel(dof), numel(num_obs), numel(num_params)]);
    if isscalar(dof),         dof        = repmat(dof,        [n,1]);  else         dof =        dof(:);  end
    if isscalar(num_obs),     num_obs    = repmat(num_obs,    [n,1]);  else     num_obs =    num_obs(:);  end
    if isscalar(num_params),  num_params = repmat(num_params, [n,1]);  else  num_params = num_params(:);  end
    if isscalar(alpha),       alpha      = repmat(alpha,      [n,1]);  else       alpha =      alpha(:);  end
end

%%
%!test
%! alpha = [];
%! dof = (100:10:200)';
%! dof = (0:5:200)';
%! dof = (0:10:500)';
%! num_params = 5;
%! num_obs = dof + num_params;
%! types = {...
%!   'student'
%!   'bonferroni'
%!   'sidak'
%!   'scheffe'
%! };
%! factors = cellfun(@(type) get_outlier_statistic (dof, num_obs, num_params, alpha, type), types, 'UniformOutput',false);
%! 
%! factors = cell2mat(factors(:)');
%! 
%! figure
%!   plot(dof, factors)
%!   legend(types)
%!   grid on
%!   xlabel('Degree of freedom')
%!   ylabel('Statistic')
%! 
%! figure
%!   plot(dof, bsxfun(@rdivide, factors, factors(:,end)))
%!   legend(types)
%!   grid on
%!   xlabel('Degree of freedom')
%!   ylabel('Statistic ratio')

