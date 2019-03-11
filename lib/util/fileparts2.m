function [dirpath, varargout] = fileparts2 (filepath)
  [dirpath, basename, ext] = fileparts (filepath);
  filename = [basename, ext];
  if (nargout == 2)
    varargout = {filename};
  else
    varargout = {basename, ext};
  end
end
