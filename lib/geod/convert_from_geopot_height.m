function varargout = convert_from_geopot_height (varargin)
%CONVERT_FROM_GEOPOT_HEIGHT: Convert from geopotential height -- and geodetic latitude and longitude --, to ellipsoidal height.

    [varargout{1:nargout}] = convert_from_geopot_height_rel (varargin{:});
end

%!test
%! % convert_from_geopot_height()
%! % nothing to test.
