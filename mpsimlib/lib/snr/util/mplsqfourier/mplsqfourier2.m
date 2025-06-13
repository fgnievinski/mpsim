function [peak, spectrum, fit, fit2, fit3, J] = mplsqfourier2 (...
obs, sat_elev, sat_azim, sfc_slope, sfc_aspect, ...
height_input, wavelength, degree, opt, J, ignore_fits)
    if (nargin <  6),  height_input = [];  end
    if (nargin <  7),  wavelength = [];  end
    if (nargin <  8),  degree = [];  end
    if (nargin <  9),  opt = [];  end
    if (nargin < 10),  J = [];  end
    if (nargin < 11),  ignore_fits = [];  end

    height_domain_vert = mplsqfourier_height (height_input);
    [height_domain_perp, sat_graz] = snr_fwd_geometry_reflection_tilted_simple (...
        height_domain_vert, sat_elev, sat_azim, sfc_slope, sfc_aspect);

    is_visible = (sat_graz > 0);
    obs(~is_visible) = NaN;
    [peak, spectrum, fit, fit2, fit3, J] = mplsqfourier (obs, sat_graz, ...
        height_domain_perp, wavelength, degree, opt, J, ignore_fits);
    
    peak.height_perp = height_domain_perp(peak.ind);
    peak.height_vert = height_domain_vert(peak.ind);
    spectrum.height_perp = height_domain_perp;
    spectrum.height_vert = height_domain_vert;    
    % confirm what mplsqfourier returned:
    assert(isequal(peak.height, peak.height_perp))
    assert(isequal(spectrum.height, spectrum.height_perp))
    % replace them:
    peak.height = peak.height_vert;
    spectrum.height = spectrum.height_vert;
end
