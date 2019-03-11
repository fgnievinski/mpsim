function varargout = get_geopot_height (varargin)
    varargout = convert_to_geopot_height (varargin{:});
end
%!test
%! out = get_geopot_height('methods');

