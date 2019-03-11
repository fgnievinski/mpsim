function coeff = snr_bias_poly_fit (obs, indep, degree, n_max)
    if (nargin < 4),  n_max = 100;  end
    if isempty(degree),  degree = 1;  end  % default
    if isnan(degree)  % value signaling disabled.
        coeff = [];
        return;
    end
    if (degree < 0)
        error('snr:bias:polyFit', 'Bad degree.')
    end
    if (degree == 0)
        % make it more robust:
        coeff = nanmedian(obs);
        return;
    end
    if (degree == 1)
        % make it more robust:
        coeff = nanrfitslm (indep, obs, n_max);
        coeff = myflip(coeff);  % (consistent with snr_bias_poly_eval)
        return;
    end
    obs = snr_bias_poly_fit_aux (obs, indep);
    coeff = nanpolyfit(indep, obs, degree);
    coeff = myflip(coeff);  % (consistent with snr_bias_poly_eval)
end

function obs2 = snr_bias_poly_fit_aux (obs, indep)
    coeff = snr_bias_poly_fit (obs, indep, 1);
    fit = snr_bias_poly_eval (coeff, indep);
    resid = obs - fit;
    std = nanstdr(resid);
    unc = get_pred_lim (0, std, sum(~isnan(obs))-1, 0.999, 'max', 'obs', 'obs');
    idx = (abs(resid) > unc);
    obs2 = setel(obs, idx, NaN);
    return
      figure
      hold on
      plot(indep, resid, '.-k')
      hline(-unc)
      hline(0)
      hline(+unc)
      plot(indep(idx), resid(idx), 'or')
end
