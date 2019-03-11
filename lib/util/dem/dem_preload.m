function dem = dem_preload (site, crop_width, dem_dir, dem_suffix)
  if (nargin < 2) || isempty(crop_width),  crop_width = [0, 500, 200, 100];  end
  if (nargin < 3),  dem_dir = [];  end
  if (nargin < 4),  dem_suffix = [];  end
  % crop_width = Inf means maximum rectangular extent even if that includes pixels with missing height.
  % crop_width = 0 means maximum rectangular extent excluding pixels with missing height.
  [zip_dir, dem_suffix] = dem_path (dem_dir, 'zip', dem_suffix);
  %tif_ext = 'tif';
  tif_ext = {'tif','tiff'};
  tmp_dir = tempdir();
  
  zip_filepath = fullfile(zip_dir, [upper(site.code) '.' dem_suffix '.zip']);  
  if ~exist(zip_filepath, 'file')
    warning('dem:dem_preload:badZip', 'Zip file "%s" nonexistent.', zip_filepath)
    dem = [];
    return
  end
  
  unzip_filepath = unzip(zip_filepath, tmp_dir);
  %unzip_filepath = strrep(unzip_filepath, '\', filesep());
    %unzip_filepath{:}  % DEBUG
  [unzip_dir, unzip_basename, unzip_ext] = cellfun(@fileparts, unzip_filepath(:), 'UniformOutput',false);
  %idx = strcmp(unzip_ext, ['.' tif_ext]);
  idx = ismember(unzip_ext, strcat('.', tif_ext));
  switch sum(idx)
  case 0
    error('snr:dem:preload:noTif', 'No tif file found in zip file "%s"', zip_filepath);
  case 1
    img_filepath = unzip_filepath{idx};
  otherwise
    img_filepath = unzip_filepath(idx);
    img_filepath = img_filepath{argmin(cellfun(@numel, img_filepath))};
    warning('snr:dem:preload:multipleTif', 'Multiple tif files found in zip file "%s" -- taking "%s".', zip_filepath, img_filepath);
  end
  
  ws = warning('off', 'map:geotiffinfo:tiffWarning');
  [grd0, R, bb] = geotiffread(img_filepath);
  grd0 = double(grd0);
  warning(ws);
  
  delete(unzip_filepath{:});

  idx = (grd0 == -340282346638528859811704183484516925440.0);
  if any(any(idx))
    %warning('snr:dem:preload:faultyTif', ...
    %  'Faulty data detected for site "%s"; setting to NaN.', site.code);
    grd0(idx) = NaN;
  end
  
  if (numel(unique(grd0(~idx))) < 2)
    warning('snr:dem:preload:emptyTif', ...
      'Empty DEM for site "%s": %s.', site.code, zip_filepath);
    dem = [];
    return;
  end
  
  mstruct0 = struct('mapprojection','none');
  mstruct1 = defaultm('utm');
  mstruct1.zone = utmzone(fliplr(mean(bb)));
  mstruct1.geoid = almanac('earth','grs80','meters');
  mstruct1 = defaultm(mstruct1);
  
  %TODO: crop to +/- 1 degree to speed up re-projection.

  [grd1, xl1, yl1] = mimtransform (grd0, R, mstruct0, mstruct1);
  xd1 = linspace(xl1(1), xl1(2), size(grd1,2));
  yd1 = linspace(yl1(1), yl1(2), size(grd1,1));
  
  [site.x, site.y] = mfwdtran(mstruct1, site.lat, site.lon);
  site.z = interp2(xd1, yd1, grd1, site.x, site.y);
  
  xd1 = xd1 - site.x;
  yd1 = yd1 - site.y;
  grd1 = grd1 - site.z;
  
  n = numel(crop_width);
  grd = cell(n,1);
  xd = cell(n,1);
  yd = cell(n,1);
  for i=1:n
    switch crop_width(i)
    case Inf
      grd{i} = grd1;
      xd{i} = xd1;
      yd{i} = yd1;
    case 0
      [grd{i}, xd{i}, yd{i}] = imcropnanborder (grd1, xd1, yd1);
    otherwise
      [grd{i}, xd{i}, yd{i}] = imcrop2 (crop_width(i)/2, grd1, xd1, yd1);
    end
  end
  
  if all(cellfun(@isempty, grd))
    warning('snr:dem:preload:emptyCropped', ...
      'Empty cropped DEM for site "%s" -- check coordinates (lat=%g, lon=%g).', ...
        site.code, site.lat, site.lon);
    dem = [];
    return;
  end
  
  if all(cellfun(@(grd_i) all(isnan(grd_i(:))), grd))
    warning('snr:dem:preload:nanCropped', ...
      'Invalid cropped DEM for site "%s" (all NaN).', site.code);
    dem = [];
    return;
  end
  
  temp = [xd, yd, grd, repmat({site.code}, [n,1]), num2cell(crop_width(:))];
  dem = cell2struct(temp, {'x','y','z','code','width'}, 2);
end

