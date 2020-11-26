function [unc, cov, rms] = lsqfourier_uncertainty_aux (...
resid, jacob, colname, rms_method, conf)
    if (nargin < 4) || isempty(rms_method),  rms_method = 'robust';  end
    if (nargin < 5),  conf = [];  end
    
    [num_obs, num_params] = size(jacob);
    
    switch lower(rms_method)
    case 'normal'
        rms = nanrmss(num_params, resid);
    case 'robust'
        rms = nanrmssr(num_params, resid);
    case {'none','ignore'}
        rms = 1;
    otherwise
        error('MATLAB:lsqfourier_uncertainty:badOpt', ...
            'Unknown rms_method = "%s".', char(rms_method));
    end

    N = jacob'*jacob;
    cov0 = inv(N);
    var0 = rms^2;
    cov = cov0 * var0; %#ok<MINV>
    var = diag(cov);
    std = sqrt(var);
    dof = num_obs - num_params;
    fac = get_confpred_lim(0, 1, dof, conf, 'two', 'avg', 'avg', 'none');
    unc = std .* fac;
    unc = num2struct(rowvec(unc), colname, 2);
    if ~isfield(unc, 'freq'),  unc.freq = [];  end
    
    %TODO: output statistical significance of each tone based on its 3x3 sub-cov matrix (hint: F dist.).
end
