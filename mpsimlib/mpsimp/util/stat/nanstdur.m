function [std_obs, std_mean, std_scale, std_obs_prior, num, wmean] = nanstdur (varargin)
%NANSTDU  Uncertainty-weighted standard deviations, robust against outliers, ignoring NaNs.
% 
% Output:
%  std_obs: standard uncertainty of observations (scaled)
%  std_mean: standard uncertainty of the mean (scaled)
%  std_scale: square-root of reduced chi-squared statistic or a-posteriori variance factor
%  std_obs_prior: typical input or a-priori standard uncertainty of observations

    [wmean, num, std_mean_unscaled, std_scale, std_obs_prior] = nanmeanur (varargin{:});
    std_mean = std_mean_unscaled .* std_scale;
    std_obs_unscaled = sqrt(std_scale.^2 + std_mean.^2);
    std_obs = std_obs_unscaled .* std_obs_prior;  % restore the observation uncertainty scale.
    %std_scale, std_obs, std_obs_unscaled  % DEBUG
end

%!test
%! % nanstdur(randn(1000,1)*pi, pi) ~ pi
%! % nanstdur(randn(1000,1)*pi, 1) ~ pi
%! % nanstdur(randn(1000,1)*1, pi) ~ 1

%!test
%! % nanstdur ()
%! rng(0)
%! std0 = 5;
%! num_obs = 100;
%! num_realiz = 100;
%! ignore_nans = true;
%! detrendit = false;
%! dim = [];
%! opt = {dim, ignore_nans, detrendit};
%! temp = NaN(num_realiz,1);
%!   rmsua = temp;
%!   rmsub = temp;
%!   rmsuc = temp;
%!   rmsud = temp;
%!   rmsue = temp;
%!   rmsr2 = temp;
%!    rms2 = temp;
%!    rmsr = temp;
%!     rms = temp;
%!     std = temp;
%!  rmsura = temp;
%!  rmsurb = temp;
%!  rmsurc = temp;
%!  rmsurd = temp;
%!  rmsure = temp;
%! for i=1:num_realiz
%!    obs = randn(num_obs,1)*std0;
%!    stda = abs(obs);
%!    stdb = randomize(stda);
%!    stdc = repmat(std0, [num_obs 1]);
%!    stdd = ones(num_obs, 1);
%!    stde = [];
%!    rmsua(i) = nanstdu (obs, stda, opt{:});
%!    rmsub(i) = nanstdu (obs, stdb, opt{:});
%!    rmsuc(i) = nanstdu (obs, stdc, opt{:});
%!    rmsud(i) = nanstdu (obs, stdd, opt{:});
%!    rmsue(i) = nanstdu (obs, stde, opt{:});
%!    rmsr2(i) = nanstdr_alt (obs, opt{:});
%!     rms2(i) = nanstd_alt (obs, opt{:});
%!     rmsr(i) = nanstdr (obs, opt{:});
%!      rms(i) = nanrmse (obs);
%!      std(i) = nanstd (obs, 1, dim);
%!   rmsura(i) = nanstdur(obs, stda, opt{:});
%!   rmsurb(i) = nanstdur(obs, stdb, opt{:});
%!   rmsurc(i) = nanstdur(obs, stdc, opt{:});
%!   rmsurd(i) = nanstdur(obs, stdd, opt{:});
%!   rmsure(i) = nanstdur(obs, stde, opt{:});
%! end
%! 
%! %%
%! temp = rmsura;
%! %figure
%! %maximize()
%! %subplot(1,2,1), hist(temp)
%! %subplot(1,2,2), hist(log(temp))
%! 
%! %%
%! name = {...
%!   'rmsua', 'rmsub', 'rmsuc', 'rmsud', 'rmsure', ...
%!   'rmsr2', 'rms2', 'rmsr', 'rms', 'std', ...
%!   'rmsura', 'rmsurb', 'rmsurc', 'rmsurd', 'rmsue' ...
%! };
%! %temp = cellfun3(@eval, name);  % WRONG!
%! temp = cellfun3(@(namei) eval(namei), name);  % anonymous function carries the necessary data.
%! m = mean(temp);
%! s = var(temp).^2;
%! t = repmat(std0, size(m));  % truth.
%! c1 = (abs(m-t)<=s);
%! c2 = (s<m/2);
%! c = c1 & c2;  % check.
%! c(isnan(m)) = true;
%! cprintf([m; s; c1; c2], '-Lc',name);
%! disp(find(~c))
%! %assert(all(c))
