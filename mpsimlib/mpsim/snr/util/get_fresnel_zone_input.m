function [siz, num, height, elev, azim, wavelength, zone] = get_fresnel_zone_input (...
height, elev, azim, wavelength, zone)
    if isempty(height),  height = 1.5;  end
    if isempty(elev),  elev = 15;  end
    if isempty(azim),  azim = 0;  end
    %if isempty(wavelength),  wavelength = [];  end  % leave it for get_gnss_wavelength.
    if isempty(zone),  zone = 1;  end
    wavelength = get_gnss_wavelength(wavelength);
    
    num_elev = numel(elev);
    num_azim = numel(azim);
    if (num_azim == 1),  azim = repmat(azim, [num_elev,1]);  num_azim = num_elev;  end
    if (num_elev == 1),  elev = repmat(elev, [num_azim,1]);  num_elev = num_azim;  end
    assert(num_azim == num_elev)
    
    num_dirs = num_elev;
    num_heights = numel(height);
    if (num_heights == 1)
        height = repmat(height, [num_dirs,1]);
        num_heights_original = num_heights;
        num_heights = num_dirs;
    end
    if (num_dirs == 1)
        azim = repmat(azim, [num_heights,1]);
        elev = repmat(elev, [num_heights,1]);
        num_dirs = num_heights;
    end
    assert(num_dirs == num_heights)
    
    num = num_heights;
    siz = size(height);
    
    height = height(:);
    elev = elev(:);
    azim = azim(:);
    
    assert(numel(wavelength) == num || isscalar(wavelength))
    assert(numel(zone) == num || isscalar(zone))
    if (num > 1) && isscalar(height),  height = repmat(height, [num,1]);  end
end
