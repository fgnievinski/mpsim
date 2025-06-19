function [ch, cl2] = colormbl (thecolormap, location, data, factor, type, tit)
  if (nargin < 1) || isempty(thecolormap),  thecolormap = dkbluered();  end
  if (nargin < 2),  location = [];  end
  if (nargin < 3),  data = [];  end
  if (nargin < 4),  factor = [];  end
  if (nargin < 5),  type = [];  end
  if (nargin < 6),  tit = [];  end
  if ~isempty(location) && ~ischar(location)
    error('MATLAB:colormbl:badArg', 'Wrong order of arguments.');
  end
  colormap(thecolormap)
  if isempty(location)
    ch=colorbar();
  else
    ch=colorbar('location',location);
  end
  cl2=colorlim(data, factor, [], ch, [], type, tit);
  if (nargout < 1),  clear ch cl2;  end  % so that they don't display.
end

