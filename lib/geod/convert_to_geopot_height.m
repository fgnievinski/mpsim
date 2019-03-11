function varargout = convert_to_geopot_height (varargin)
%CONVERT_TO_GEOPOT_HEIGHT: Convert to geopotential height, given geodetic coordinates.

    [varargout{1:nargout}] = convert_to_geopot_height_rel (varargin{:});
    %[varargout{1:nargout}] = convert_to_geopot_height_abs (varargin{:});  % WRONG!
end

%!test
%! % convert_to_geopot_height()
%! % nothing to test.
