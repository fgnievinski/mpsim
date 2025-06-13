function dem = do_dem_aux (site, crop_width, cmap, dem_suffix, skip_already_done, overwrite_plots, dem_dir)
  if (nargin < 5),  skip_already_done = false;  end
  if (nargin < 6),  overwrite_plots = false;  end
  if (nargin < 7),  dem_dir = [];  end
  if ~iscell(cmap),  cmap = {cmap};  end
  site.code = lower(site.code);
  
  dem = dem_load (site, dem_dir, dem_suffix);
  if skip_already_done && ~isempty(dem),  dem = [];  return;  end
  if isempty(dem) || ~isequal([dem.width], crop_width)
    dem = dem_preload(site, crop_width, dem_dir, dem_suffix);
    if isempty(dem),  return;  end
    dem_save(dem, dem_dir, dem_suffix);
  end
  
  for i=1:numel(cmap)
    dem_plot(dem, cmap{i}, [], dem_dir, dem_suffix, overwrite_plots);
  end
  dem_plot2(dem, [], dem_dir, dem_suffix, overwrite_plots);
  
  for j=1:numel(crop_width)
    demb = dem([dem.width] == crop_width(j));
    
    [demb.aspect, demb.slope] = mygradientm (demb.z, [mode(diff(demb.x)), mode(diff(demb.y))]);
    dem_plot3(demb.code, demb.x, demb.y, demb.aspect, 'Aspect', 'degrees', [0 360], 0:45:360, 'hsv', dem_dir, dem_suffix, [], demb.width, overwrite_plots)
    dem_plot3(demb.code, demb.x, demb.y, demb.slope,  'Slope',  'degrees', [], [], [], dem_dir, dem_suffix, [], demb.width, overwrite_plots)

    [demb.X, demb.Y] = meshgrid(demb.x, demb.y);
    demb.azim = azimuth_aux(demb.X, demb.Y);
    %[demb.along, demb.across] = slopeaspect2alongacross (demb.aspect, demb.slope, demb.azim);  % WRONG!
    [demb.along, demb.across] = slopeaspect2alongacross (demb.slope, demb.aspect, demb.azim);
    dem_plot3(demb.code, demb.x, demb.y, demb.along,  'Along',  'degrees', [], [], 'dkbluered', dem_dir, dem_suffix, [], demb.width, overwrite_plots)
    dem_plot3(demb.code, demb.x, demb.y, demb.across, 'Across', 'degrees', [], [], 'dkbluered', dem_dir, dem_suffix, [], demb.width, overwrite_plots)
  end
end

