function power = snr_fwd_incident_power (geom, setup)
    opt = setup.opt;
    power_min = opt.incident_power_min;
    if opt.disable_incident_power_trend,  power = power_min;  return;  end
    power_trend = snr_fwd_incident_power_trend (geom, setup);
    if isnan(power_trend),  power = power_min;  return;  end
    power_trend_min = opt.incident_power_trend_min;
    %power = power_trend - power_trend_min + power_min;
    %power = power_trend ./ power_trend_min .* power_min;
    power = (power_min ./ power_trend_min) .* power_trend;
    % (Transmitted power is different for different satellite directions;
    % although GNSS were designed to minimize this variation, 
    % which is expected to be at most 2 dB, it is non-zero.)    
end
