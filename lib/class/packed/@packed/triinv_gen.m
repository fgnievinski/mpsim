function varargout = triinv_gen (varargin)
    if ~strcmp(get_caller_name, 'triinv'),
        error ('packed:triinv_gen:privFunc', 'This is a private function.');
    end

    error ('packed:triinv_gen:badOpt', ...
        ['A packed matrix cannot be general -- it must be'...
         ' positive-definite, symmetric indefinite, or triangular.']);
end

