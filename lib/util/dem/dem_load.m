function dem = dem_load (site, dem_dir, dem_suffix)
  if (nargin < 2),  dem_dir = [];  end
  if (nargin < 3),  dem_suffix = [];  end
  dir = dem_path (dem_dir, 'mat', dem_suffix);
  filename = fullfile(dir, [site.code '.mat']);
  %disp(filename)  % DEBUG
  if ~exist(filename, 'file'),  dem = [];  return;  end
  dem = getfield(load(filename), 'dem'); %#ok<GFLD>
end

