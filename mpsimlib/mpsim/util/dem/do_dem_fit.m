function fit = do_dem_fit (site, dem, crop_width_fit, azim_mid, azim_tol, dem_suffix)
  site.code = lower(site.code);
  
  if isempty(dem),  dem = dem_load (site, [], dem_suffix);  end
  if isempty(dem),  fit = [];  return;  end
  crop_width_dem = [dem.width];
  assert(all(ismember(crop_width_fit, crop_width_dem)))
  
  m = numel(azim_mid);  assert(any(numel(azim_tol) == [m, 1]))
  for j=1:numel(crop_width_fit)
    dema = dem([dem.width] == crop_width_fit(j));
  
    fit = struct();
    fit.code = site.code;
    fit.azim_mid = azim_mid;
    fit.azim_tol = azim_tol;
    demc = repmat(dema, [m,3]);  % demc(:,[1,2,3]) are resp. the DEM itself, azimuth-wedge plane fit, and residual.
    for i=1:m
      [fit.coeff(:,i), fit.slope(i), fit.aspect(i), demc(i,2).z, demc(i,3).z, fit.rmsr(i), fit.rmsz(i), fit.var_red(i)] = plane_fit_azim (...
        demc(i,1).x, demc(i,1).y, demc(i,1).z, fit.azim_mid(i), fit.azim_tol(i), demc(i,1).width/2);
    end
    [fit.along, fit.across] = slopeaspect2alongacross(fit.slope, fit.aspect, fit.azim_mid);
    dem_fit_save(fit, [], dem_suffix, dema.width)
    %TODO: plot map of azimuth-wedge plane fit.
  end  % 
end
