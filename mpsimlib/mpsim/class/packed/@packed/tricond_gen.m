function varargout = tricond_gen (varargin)
    if ~strcmp(get_caller_name, 'tricond'),
        error ('packed:tricond_gen:privFunc', 'This is a private function.');
    end

    error ('packed:tricond_gen:badInput', ...
        ['A packed matrix cannot be general -- it must be'...
         ' positive-definite, symmetric indefinite, or triangular.']);
end

%!test
%! % tricond_gen ()
%! warning('off', 'test:noFuncCall');

%!error
%! s = lasterr ('', '');
%! tricond_gen (packed(eye(2)));

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:tricond_gen:privFunc');


%!error
%! n = 10;
%! tricond (packed(eye(n)), 'general', 1);

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:tricond_gen:badInput');

%!test
%! warning('on', 'test:noFuncCall');

