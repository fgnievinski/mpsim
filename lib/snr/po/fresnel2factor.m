function factor = fresnel2factor (fresnel_zone)
    if (fresnel_zone == 1)
        factor = 1/2;
        return;
    end
    error('snr:fresnel2factor:unkZone', ...
        'Unknown truncation factor for Fresnel zone #%f.', fresnel_zone);
    % non-integer Fresnel zone would have a complex-valued truncation factor.
end
