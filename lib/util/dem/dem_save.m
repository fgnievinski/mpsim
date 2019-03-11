function dem_save (dem, dem_dir, dem_suffix)
  if (nargin < 2),  dem_dir = [];  end
  if (nargin < 3),  dem_suffix = [];  end
  dir = dem_path (dem_dir, 'mat', dem_suffix);
  save(fullfile(dir, [dem(1).code '.mat']), 'dem');
end

