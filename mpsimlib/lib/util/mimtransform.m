function [img2, varargout] = mimtransform (img, R, mstruct, mstruct2, ...
interp, fillval, varargin)
  if (nargin < 5),  interp = 'bilinear';  end
  if (nargin < 6),  fillval = NaN;  end
  %temp1 = [1,0],  temp2 = minv(mfwd(temp1)),  temp1-temp2  % DEBUG
  tform = maketform('custom', 2, 2, @mfwd, @minv, []);
  [img2, varargout{1:nargout-1}] = imtransform(img, tform, interp, ...
    'FillValues',fillval, varargin{:}, 'XYScale',get_scale(img));
  return;
  function scale = get_scale (img)
    ind = get_border_ind(img);
    %ind = (1:numel(img))';  % DEBUG (all pixels!)
    [I,J] = ind2sub(size(img), ind);
    colrow = [J,I];
    xy = mfwd(colrow);
    dist_all = get_dist_all (xy(:,1), xy(:,2));
    dist_all(dist_all==0) = Inf;
    scale = min(dist_all(:));
    %dist = sqrt(sum(diff(xy,1,1).^2,2));
    %scale = min(dist);
  end
  function dist_all = get_dist_all (x, y)
    dist_all = sqrt(...
        bsxfun(@minus, x, x').^2 + ...
        bsxfun(@minus, y, y').^2 );
  end
  function xy = mfwd (colrow, ignore) %#ok<INUSD>
    rowcol = fliplr(colrow);
    uv = pix2map(R, rowcol);
    if strcmpi(mstruct.mapprojection, 'none')
      lon = uv(:,1);
      lat = uv(:,2);
    else
      [lat, lon] = minvtran(mstruct, uv(:,1), uv(:,2));
      if (all(mstruct2.maplonlimit) >= 0)
        lon = azimuth_range_positive(lon);
      end
    end
    [x, y] = mfwdtran(mstruct2, lat, lon);
    xy = [x, y];
  end
  function colrow = minv (xy, ignore) %#ok<INUSD>
    [lat, lon] = minvtran(mstruct2, xy(:,1), xy(:,2));
    if (all(mstruct2.maplonlimit >= 0))
      lon = azimuth_range_positive(lon);
    end
    if strcmpi(mstruct.mapprojection, 'none')
      u = lon;
      v = lat;
    else
      [u, v] = mfwdtran(mstruct, lat, lon);
    end
    uv = [u, v];
    rowcol = map2pix(R, uv);
    colrow = fliplr(rowcol);
  end
end

