function densemap = snr_setup_ant_densemap_load (sphharm, n)
    if (nargin < 2),  n = 150;  end

    %azim_domain = linspace(-180, +180, n);
    azim_domain = linspace(0, 360, n);
    elev_domain = linspace(-90, +90, n);
    [azim_grid, elev_grid] = meshgrid(azim_domain, elev_domain);

    azim = azim_grid(:);
    elev = elev_grid(:);
    temp = snr_setup_ant_sphharm_eval (elev, azim, sphharm);
    final_grid = reshape(temp, size(azim_grid));

    densemap = struct(...
        'final_grid',final_grid, ...
        'azim_grid',azim_grid, ...
        'elev_grid',elev_grid, ...
        'azim_domain',azim_domain, ...
        'elev_domain',elev_domain  ...
    );

    return
    figure
      %imagesc(ampl_grid)
      imagesc(azim_domain, elev_domain, final_grid)
      %imagesc(azim_grid, elev_grid, final_grid)
      xlabel('Azimuth (degrees)')
      ylabel('Elevation angle (degrees)')
      set(gca, 'YDir','normal')
      set(gca, 'XTick',0:90:360)
      %set(gca, 'XTick',-180:90:+180)
      set(gca, 'YTick',-90:30:+90)
      h = colorbar;  %title(h, sprintf('%s (%s)', ))
      %title(data.filename, 'Interpreter','none')
end

