function dem_fit_save (fit, dem_dir, dem_suffix, dem_width)
  if (nargin < 2),  dem_dir = [];  end
  if (nargin < 3) || isempty(dem_suffix),  dem_suffix = 'NED13';  end
  fit_dir = dem_path (dem_dir, 'fit', dem_suffix);
  save(fullfile(fit_dir, [fit.code '.' num2str(dem_width) '.mat']), 'fit');
  
  temp = vertcat(fit.azim_mid, fit.azim_tol, fit.along, fit.across, fit.slope, fit.aspect, fit.rmsr, fit.rmsz, fit.var_red, fit.coeff);
  temp2 = cprintf(temp, '-T',sprintf('\n'), '-L','%% ', '-Lr',{'azim (deg)', 'tol (deg)', 'along (deg)', 'across (deg)', 'slope (deg)', 'aspect (deg)', 'rms resid (m)', 'rms raw (m)', 'var reduction', 'mean (m)', 'dz/dx (m/m)', 'dz/dy (m/m)'});
  temp3 = cprintf(temp, '-T',sprintf('\n'));
  fid = fopen(fullfile(fit_dir, [fit.code  '.' num2str(dem_width) '.dat']), 'wt+');
  fprintf(fid, '%s', temp2');
  fprintf(fid, '%s', temp3');
  fclose(fid);
end

