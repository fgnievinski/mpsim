function CPN_estim = snr_fwd_tracking_loss (CPN_true, setup)
% SEE ALSO: snr_setup_tracking_loss

    opt = setup.opt;
    CPN_estim = CPN_true;  % assume ideal estimator by default.    
    if opt.disable_tracking_loss,  return;  end
    data = opt.tracking_loss_data;
    if isscalar(data) && ~isstruct(data) && ~isnan(data)
        CPN_estim = CPN_true ./ decibel_power_inv(data);
    elseif strcmpi(opt.freq_name, 'L2') && strcmpi(opt.code_name, 'P(Y)')
        CPN_true_db = decibel_power(CPN_true);
        s2 = CPN_true_db;
        s2_min = decibel_power(opt.incident_power_min);
        sc_min = decibel_power(data.sc_incident_power_min);
        sc = s2 - s2_min + sc_min - data.sc_loss;
        if isempty(setup.opt.extrap_tracking_loss)
            setup.opt.extrap_tracking_loss = true;
            need_to_extrap = any(sc < min(data.sc)) || any(sc > max(data.sc));
            if need_to_extrap
                warning('snr:snr_fwd_tracking_loss:Extrap', ...
                    ['Extrapolating tracking losses; '...
                     'consider forcing sett.opt.extrap_tracking_loss '...
                     'as desired (true/false), or setting '...
                     'sett.opt.disable_tracking_loss.']);
            end
        end
        if setup.opt.extrap_tracking_loss
            extra = {'extrap'};
        else
            extra = {NaN};
        end
        method = 'linear';
        %method = 'cubic';  % risky when extrap.
        sd = interp1(data.sc, data.sd, sc, ['*' method], extra{:});
        s2 = sc + sd;
        %s2 = sc - sd;  % WRONG!
        CPN_estim = decibel_power_inv(s2);
        return
        % DEBUG:
        figure
          hold on
          plot(data.sc, data.sd, 'o-k')
          plot(sc, sd, '.-r')
          grid on
    end
end
