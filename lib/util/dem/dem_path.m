function [dir, dem_suffix] = dem_path (dem_dir, subdir, dem_suffix)
  if (nargin < 2) || isempty(dem_dir)
    if ispc()
      dem_dir = 'c:\work\data\dem\';
    else
      dem_dir = '/bowie/data/dem/';
    end
  end
  if (nargin < 2) || isempty(subdir),  subdir = '';  end
  %if strcmp(subdir, 'zip') && isunix(),  subdir = '';  end
  if (nargin < 3) || isempty(dem_suffix),  dem_suffix = 'NED13';  end
  if ~iscell(subdir),  subdir = {subdir};  end
  dir = fullfile(dem_dir, subdir{:}, dem_suffix);  
  if ~exist(dir, 'dir')
      %dir
      mkdir(dir);
  end
end

