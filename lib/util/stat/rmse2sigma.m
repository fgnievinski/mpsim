function sigma = rmse2sigma (rmse, num_obs, num_params, flag)
    if (nargin < 4) || isempty(flag),  flag = 0;  end  % consistent w/ std.m
    assert(flag == 0 || flag == 1)
    sigma = rmse .* sqrt( (num_obs - flag) ./ (num_obs - num_params) );
end
