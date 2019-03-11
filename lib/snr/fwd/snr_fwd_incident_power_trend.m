function power = snr_fwd_incident_power_trend (geom, setup)
    opt = setup.opt;
    elev = geom.direct.dir.local_ant.elev;
    data = opt.incident_power_trend_data;
    if isscalar(data) && ~isstruct(data) && isnan(data)
        power = NaN;
        return;
    end
    power = ppval(data.incident_power_pp, elev);
    %power = interp1_fastest(data.elev, data.incident_power, elev, ...
    %    'cubic', 'extrap');
    % TODO: model trend in power vs. elevation angle, given 
    % transmitt antenna gain pattern and distance satellite-receiver.
end

