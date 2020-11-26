function coeff = snr_bias_poly_fit (obs, indep, degree, ~)
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
% nanrfitslm was disabled because it was non-repeatable, 
% using a random sample to keep the speed reasonable;
% also, snr_bias_poly_fit_aux below already does 
% robustification against outliers.
%     if (degree == 1)
%         % make it more robust:
%         %n_max = 100;  coeff = nanrfitslm (indep, obs, n_max);
%         coeff = myflip(coeff);  % (consistent with snr_bias_poly_eval)
%         return;
%     end
    obs = snr_bias_poly_fit_aux (obs, indep);
    coeff = nanpolyfit(indep, obs, degree);
    coeff = myflip(coeff);  % (consistent with snr_bias_poly_eval)
end

function obs2 = snr_bias_poly_fit_aux (obs, indep)
    %n_max = 100;  coeff = nanrfitslm (indep, obs, n_max);
    coeff = nanpolyfit(indep, obs, 1);
    coeff = myflip(coeff);  % (consistent with snr_bias_poly_eval)    
    fit = snr_bias_poly_eval (coeff, indep);
    resid = obs - fit;
    std = nanstdr(resid);
    unc = get_pred_lim (0, std, sum(~isnan(obs))-1, 0.999, 'max', 'obs', 'obs');
    idx = (abs(resid) > unc);
    obs2 = setel(obs, idx, NaN);
    return
    %%
      figure
      hold on
      plot(indep, resid, '.-k')
      hline(-unc)
      hline(0, '--k')
      hline(+unc)
      plot(indep(idx), resid(idx), 'or')
end
