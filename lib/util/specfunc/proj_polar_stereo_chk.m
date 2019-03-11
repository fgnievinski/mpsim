function proj_polar_stereo_chk (lat_ts, lat_0, k_0, nparallels, mapparallels)
    if ( (~isempty(nparallels) && nparallels > 1) ...
         || length(mapparallels) > 1 )
        error ('Should not specify more than one standard parallel.');
    end
    if    (  isempty(lat_ts) &&  isempty(k_0) ) ...
       || ( ~isempty(lat_ts) && ~isempty(k_0) )
        error (['Should define only one of either latitude of true scale '...
               'or scale factor at origin.']);
    end
    if ( abs(lat_0) ~= 90 )
        error (['Origin should be at either North or South pole only ' ...
               '(this is a polar aspect stereographic projection).']);
    end
    if ( ~isempty(lat_ts) && sign(lat_0) ~= sign(lat_ts) )
        error (['Latitude of true scale should be in the same '...
               'hemisphere as the origin (North or South pole) is.']);
    end
end

