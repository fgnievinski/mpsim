function answer = numeltriorder (n)
    error(nargchk2(1, 1, nargin, 'struct', 'packed:numeltriorder'));
    error(nargoutchk2(0, 1, nargout, 'struct', 'packed:numeltriorder'));
    
    if isempty(n)
        answer = 0;
        return;
    end
    if ~isscalar(n)
        error('packed:numeltriorder:badInput',...
        'First parameter should be matrix order (scalar).');
    end
    if (n == 1)
        error('packed:numeltriorder:orderOne',...
        'Not defined for matrix of order 1.');
    end

    answer = (n*n - n) / 2 + n;
end

%!test
%! for i=1:10
%!     n = round(rand*100);
%!     if (n < 2),  continue;  end
%!     M = zeros(n);
%!     temp = triu(true(n));
%!     myassert( numeltriorder(n), sum(temp(:)) );
%!     myassert( numeltriorder(n), sum(temp(:)) );
%!     myassert( numeltriorder(n), sum(temp(:)) );
%! end


%!test
%! myassert(numeltriorder ([]), 0);


%!error
%! lasterr('', '')
%! numeltriorder ()

%!test
%! % numeltriorder ()
%! s = lasterror;
%! myassert(strendi('notEnoughInputs', s.identifier));


%!error
%! lasterr('', '')
%! numeltriorder (1, 2)

%!test
%! % numeltriorder ()
%! s = lasterror;
%! myassert(strendi('tooManyInputs', s.identifier));


%!error
%! lasterr('', '')
%! numeltriorder ([1])

%!test
%! % numeltriorder ()
%! s = lasterror;
%! myassert(strcmp(s.identifier, 'packed:numeltriorder:orderOne'));


%!error
%! lasterr('', '')
%! numeltriorder ([1 2 3; 4 5 6])

%!test
%! % numeltriorder ()
%! s = lasterror;
%! myassert(strcmp(s.identifier, 'packed:numeltriorder:badInput'));

