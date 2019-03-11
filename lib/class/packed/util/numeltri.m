function answer = numeltri (A)
    error(nargchk2(1, 1, nargin, 'struct', 'packed:numeltri'));
    error(nargoutchk2(0, 1, nargout, 'struct', 'packed:numeltri'));

    if ~issquare(A)
        error('packed:numeltri:notSquare',...
        'Not defined for not square matrices.');
    end
        
    [m, n] = size(A);
    myassert (m, n);
    
    answer = numeltriorder(n);
end

%!test
%! for i=1:10
%!     n = round(rand*100);
%!     if (n < 2),  continue;  end
%!     M = zeros(n);
%!     temp = triu(true(n));
%!     myassert( numeltri(M), sum(temp(:)) );
%!     myassert( numeltri(M), sum(temp(:)) );
%!     myassert( numeltri(M), sum(temp(:)) );
%! end


%!test
%! myassert(numeltri ([]), 0);


%!error
%! lasterr('', '')
%! numeltri ()

%!test
%! % numeltri ()
%! s = lasterror;
%! myassert(strendi('notEnoughInputs', s.identifier));


%!error
%! lasterr('', '')
%! numeltri (1, 2)

%!test
%! % numeltri ()
%! s = lasterror;
%! myassert(strendi('tooManyInputs', s.identifier));


%!error
%! lasterr('', '')
%! numeltri ([1])

%!test
%! % numeltri ()
%! s = lasterror;
%! myassert(strcmp(s.identifier, 'packed:numeltriorder:orderOne'));


%!error
%! lasterr('', '')
%! numeltri (zeros(2, 3))

%!test
%! % numeltri ()
%! s = lasterror;
%! myassert(strcmp(s.identifier, 'packed:numeltri:notSquare'));

