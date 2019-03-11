function [elev, azim, dir_reflected, pos_reflected, dist] = get_iso_elev (...
setup, elev_domain, n)
    if (nargin < 3),  n = 100;  end
    azim_domain = linspace(0,360, n);
    [elev_grid, azim_grid] = meshgrid(elev_domain, azim_domain);
    elev = elev_grid(:);
    azim = azim_grid(:);
    setup.sat.epoch = NaN(size(elev));
    dir_incident.elev = elev;
    dir_incident.azim = azim;

    [dir_reflected, pos_reflected, dist] = ...
        snr_fwd_geometry_reflection_tilted (...
        dir_incident, setup);
end

