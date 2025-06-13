function fid = fopen_error (filepath, mode)
    if (nargin < 2),  mode = 'r';  end
    [fid, errmsg] = fopen (filepath, mode);
    if (fid ~= -1),  return;  end
    error('MATLAB:FileIO:InvalidFid', 'Couldn''t open file "%s".\n%s', filepath, errmsg);
end
