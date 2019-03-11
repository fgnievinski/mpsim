function [outlier_idx, lower_conf_limit, upper_conf_limit] = ...
is_outlier (obs, mean, var, signif, dof, dist)
    if ~isvector(obs)
        error ('obs should be a vector.');
    end
    
    N = length(obs);
    if (nargin < 4) || isempty(dof),  dof = N - 1;  end
    if (nargin < 5) || isempty(signif),  signif = 1-0.99;  end
    if (nargin < 6) || isempty(dist),  dist = 't';  end
    obs = colvec(obs);
    std = sqrt(var);
    
    if (dist(1) == 'n')  % normal distribution
        d = norminv(1-signif/2, 0, 1);
    elseif (dist(1) == 't')  % Student's t distribution
        d = tinv(1-signif/2, N-1);
    elseif (dist(1) == 'T')  % Tau distribution
        d = tauinv(1-signif/2, N-1);
    else
        error ('Distribuition %s unknown.', dist);
    end
        
    std = sqrt(dof/N) * d * std;
    if ( ~isequal(size (std), size(obs)) )  
        % we don't have one std for each obs
        std = repmat(std, N, 1);
    end
    mean = repmat(mean, N, 1);
    lower_conf_limit = mean - std;
    upper_conf_limit = mean + std;
    
    notoutlier_idx = (lower_conf_limit < obs & obs < upper_conf_limit);
    
    outlier_idx = ~notoutlier_idx;
end

%!shared obs, pop_mean, pop_var, signif, outlier_idx
%! % generate data
%! N = 25;
%! pop_mean = rand;
%! pop_std = rand;
%! pop_var = pop_std.^2;
%! obs_normal = randn(N, 1);
%! temp_pop_std = repmat(pop_std, N, 1);
%! temp_pop_mean = repmat(pop_mean, N, 1);
%! obs = obs_normal .* temp_pop_std + temp_pop_mean;
%! 
%! % set outliers
%! outlier_idx = zeros(size(obs));
%! outlier_idx(5,:) = 1;
%! %outlier_idx  % debug
%! old_obs = obs;
%! obs = obs + outlier_idx .* obs * 100;  % add zero to non-outliers
%! myassert((obs ~= old_obs) == outlier_idx);
%! signif = 0.0001;  % small significance level, so that 
%!                   % the probability of Type I errors is small.

%!test
%! % Population mean known, population variance known.
%! dist = 'n';
%! dof = size(obs, 1);
%! [answer_outlier_idx, lower_conf_limit, upper_conf_limit] = ...
%!     is_outlier (obs, pop_mean, pop_var, signif, dof, dist);
%! %answer_outlier_idx - outlier_idx  % debug
%! myassert(isequal(answer_outlier_idx, outlier_idx));

%!test
%! % Population mean known, population variance unknown.
%! indep_sample_var = std2(obs).^2;
%! dof = size(obs, 1);
%! dist = 't';
%! [answer_outlier_idx, lower_conf_limit, upper_conf_limit] = ...
%!     is_outlier (...
%!     obs, pop_mean, indep_sample_var, signif, dof, dist);
%! %answer_outlier_idx - outlier_idx  % debug
%! myassert(isequal(answer_outlier_idx, outlier_idx));

%!#test
%! % TEST DISABLED!!!
%! % Population mean unknown, population variance known.
%! obs  % debug
%! pop_mean  % debug
%! pop_var  % debug
%! sample_mean = mean(obs)
%! dist = 'n';
%! dof = size(obs, 1) - 1;
%! [answer_outlier_idx, lower_conf_limit, upper_conf_limit] = ...
%!     is_outlier (...
%!     obs, sample_mean, pop_var, signif, dof, dist)
%! outlier_idx 
%! answer_outlier_idx
%! %answer_outlier_idx - outlier_idx  % debug
%! myassert(isequal(answer_outlier_idx, outlier_idx));

%!test
%! % Population mean unknown, population variance unknown.
%! % Should use the tau-.
%! sample_var = std (obs);
%! dof = length(obs) - 1;
%! dist = 'T';
%! [answer_outlier_idx, lower_conf_limit, upper_conf_limit] = ...
%!     is_outlier (...
%!     obs, pop_mean, sample_var, signif, dof, dist);
%! %answer_outlier_idx - outlier_idx  % debug
%! myassert(isequal(answer_outlier_idx, outlier_idx));

