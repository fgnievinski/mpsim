function latm = convert_to_latm (lat, h, ell)
%CONVERT_TO_LATM: Return meridian arc-length (at non-zero height), given geodetic latitude and height.

    myassert (size(lat,1) >= size(lat,2));
    myassert (length(lat), length(h));

    latm = get_meridian_arclen (lat, ell) + h .* (lat*pi/180 - 0);
end
