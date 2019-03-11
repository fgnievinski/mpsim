function [param_avg, cov_avg, std_factor, resid] = mean_vec_wei (param, cov, is_var_factor_global)
%MEAN_VEC_WEI  Vectorial weighted mean.

    if (nargin < 3) || isempty(is_var_factor_global),  is_var_factor_global = true;  end
    
    sum3 = @(x) sum(x, 3);
    [n, m, p] = size(param);
    nm = max(n, m);
    param = param';
    %whos wei param  % DEBUG
    
    wei = inv(cov);
    u = wei * param; %#ok<MINV>
    u = sum3(u);
    N = sum3(wei);
    cov_avg = inv(N);
    param_avg = cov_avg * u; %#ok<MINV>    
    %whos param param_avg  % DEBUG
    resid = minus_all(param, param_avg);

    if is_var_factor_global    
        sum_sq = resid' * wei * resid; %#ok<MINV>
        sum_sq = sum3(sum_sq);
        dof = nm*p - nm;
        var_factor = sum_sq/dof;
        cov_avg = times_all(cov_avg, var_factor);
        std_factor = sqrt(var_factor);
    else
        sum_sq = resid.^2 ./ diag(wei);
        sum_sq = sum3(sum_sq);
        dof = p - 1;
        var_factor = sum_sq/dof;
        std_factor = sqrt(var_factor);
        temp = std_factor * std_factor';
        cov_avg = cov_avg .* temp;
    end
    
    param_avg = param_avg';
    std_factor = std_factor';
    resid = resid';
end
