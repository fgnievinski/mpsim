function [unc, cov, rms] = mplsqfourier_uncertainty_aux (...
resid, jacob, colname, wavelength, rms_method)

%TODO: refactor using lsqfourier_uncertainty_aux.m

    if (nargin < 4),  wavelength = [];  end
    if (nargin < 5) || isempty(rms_method),  rms_method = 'robust';  end
    
    [num_obs, num_params] = size(jacob);
    
    switch lower(rms_method)
    case 'normal'
        rms = nanrmss(num_params, resid);
    case 'robust'
        rms = nanrmssr(num_params, resid);
    case {'none','ignore'}
        rms = 1;
    otherwise
        error('snr:mplsqfourier_uncertainty:badOpt', ...
            'Unknown rms_method = "%s".', char(rms_method));
    end

    N = jacob'*jacob;
    cov0 = inv(N);
    var0 = rms^2;
    cov = cov0 * var0; %#ok<MINV>
    std = sqrt(diag(cov));
    dof = num_obs - num_params;
    unc = diff2half(get_pred_lim(0, std, dof, [], [], 'avg', 'avg', 'none'));
    unc = num2struct(rowvec(unc), colname, 2);

    wavelength = get_gnss_wavelength (wavelength);
    dh_df = wavelength / 2;
    if ~isfield(unc, 'freq'),  unc.freq = [];  end
    unc.height = abs(dh_df) * unc.freq;
end
