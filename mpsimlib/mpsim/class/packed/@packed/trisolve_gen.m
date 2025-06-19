function varargout = trisolve_gen (varargin)
    if ~strcmp(get_caller_name, 'trisolve'),
        error ('packed:trisolve_gen:privFunc', 'This is a private function.');
    end

    error ('packed:trisolve_gen:badOpt', ...
        ['A packed matrix cannot be general -- it must be'...
         ' positive-definite, symmetric indefinite, or triangular.']);
end

%!test
%! % trisolve_gen ()
%! warning('off', 'test:noFuncCall');

%!error
%! s = lasterr ('', '');
%! trisolve_gen (packed(eye(2)));

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:trisolve_gen:privFunc');


%!error
%! n = 10;
%! trisolve (rand(n,1), packed(eye(n)), 'general');

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:trisolve_gen:badOpt');

%!test
%! warning('on', 'test:noFuncCall');


