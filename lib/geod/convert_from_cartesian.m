function varargout = convert_from_cartesian (varargin)
%CONVERT_FROM_CARTESIAN: Convert from global Cartesian coordinates, to geodetic curvilinear coordinates.

    [varargout{1:nargout}] = convert_to_geodetic (varargin{:});
end

%!test
%! % convert_from_cartesian()
%! % nothing to test.
