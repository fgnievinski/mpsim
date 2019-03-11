function delay_excess = fresnel2delay (fresnel_zone, wavelength)
    delay_excess  = fresnel_zone .* wavelength ./ 2;
end
