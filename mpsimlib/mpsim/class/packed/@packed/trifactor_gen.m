function varargout = trifactor_gen (varargin)
    error ('packed:trifactor_gen:badInput', ...
        ['A packed matrix cannot be general -- it must be'...
         ' positive-definite, symmetric indefinite, or triangular.']);
end

%!error
%! s = lasterr ('', '');
%! trifactor_gen (packed(eye(2)));

%!test
%! % trifactor_gen ()
%! s = lasterror;
%! myassert (s.identifier, 'packed:trifactor_gen:badInput');

