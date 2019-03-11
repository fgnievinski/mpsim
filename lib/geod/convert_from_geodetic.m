function varargout = convert_from_geodetic (varargin)
%CONVERT_FROM_GEODETIC:  Convert from geodetic (ellipsoidal curvilinear) coordinates, to global Cartesian coordinates.

    [varargout{1:nargout}] = convert_to_cartesian (varargin{:});
end

%!test
%! % convert_from_geodetic()
%! % nothing to test.
