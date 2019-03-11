% (Transmitted power is different for different directions;
% although GPS was designed to minimize this variation, 
% which is expected to be at most 2 dB, it is non-zero.)
function power = get_gps_power_incident (geom, setup)
    opt = setup.opt;
    power_min = opt.power_incident_min;
    if opt.disable_incident_power_trend,  power = power_min;  return;  end
    power_trend = get_gps_power_incident_trend (geom, setup);
    if isnan(power_trend),  power = power_min;  return;  end
    power_trend_min = opt.power_incident_trend_min;
    %power = power_trend - power_trend_min + power_min;
    %power = power_trend ./ power_trend_min .* power_min;
    power = (power_min ./ power_trend_min) .* power_trend;
end

