function varargout = get_reflection_coeff_slab (varargin)
    [varargout{1:nargout}] = get_reflection_coeff_layered (varargin{:});
    % TODO: implement specialized version instead of reutilizing more general one; then validate the more general one.
end

