function [answer, answer2, varargout] = size (A, i)
    switch nargin
    case 1
        switch nargout
        case 0
            answer = A.size;
        case 1
            answer = A.size;
        case 2
            answer  = A.size(1);
            answer2 = A.size(2);
        otherwise
            answer  = A.size(1);
            answer2 = A.size(2);
            varargout = num2cell(ones(nargout -2, 1));
        end            
    case 2
        if (nargout > 1)
            error('blockdiag:size:badopt', ...
            'Unknown command option.');
        end
        if (i < 1)
            error('blockdiag:size:getdimarg:dimensionMustBePositiveInteger',...
                ['Dimension argument must be a positive integer scalar'...
                 ' in the range 1 to 2^31.']);
        elseif (i == 1 || i == 2)
            answer  = A.size(i);
        elseif (i > 2)
            answer = 1;
        end
    end
end

%!test
%! A = blockdiag(eye(2,2));
%! myassert (isblockdiag(A));
%! myassert (size(A), [2, 2]);

%!test
%! A = blockdiag({});
%! myassert (isblockdiag(A));
%! myassert (size(A), [0, 0]);

%!test
%! A = blockdiag;
%! myassert (isblockdiag(A));
%! myassert (size(A), [0, 0]);

%!error
%! lasterr('', '');
%! A = blockdiag;
%! myassert (isblockdiag(A));
%! size(A, 1, 2, 3);

%!test
%! % size()
%! s = lasterror;
%! myassert (strendi('TooManyInputs', s.identifier));

%!error
%! lasterr('', '');
%! A = blockdiag;
%! myassert (isblockdiag(A));
%! size(A, 0);

%!test
%! % size()
%! s = lasterror;
%! myassert (s.identifier, ...
%!     'blockdiag:size:getdimarg:dimensionMustBePositiveInteger');

%!test
%! A = blockdiag({});
%! myassert (isblockdiag(A));
%! [m, n] = size(A);
%! myassert ([m, n], [0, 0]);

%!test
%! A = blockdiag(eye(4), eye(2,2));
%! myassert (isblockdiag(A));
%! [m, n] = size(A);
%! myassert ([m, n], [6, 6]);

%!test
%! A = blockdiag(eye(4), eye(2));
%! myassert (isblockdiag(A));
%! [m, n, o, p] = size(A);
%! myassert ([m, n, o, p], [6, 6, 1, 1]);

%!test
%! A = blockdiag(eye(4), eye(3,2));
%! myassert (isblockdiag(A));
%! [m, n] = size(A);
%! myassert ([m, n], [7, 6]);

%!test
%! A = blockdiag;
%! size(A);
%! myassert (ans, [0, 0]);

