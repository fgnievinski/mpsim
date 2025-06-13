function [answer, answer2, varargout] = size (A, i)
    switch nargin
    case 1
        switch nargout
        case 0
            answer = [A.order, A.order];
        case 1
            answer = [A.order, A.order];
        case 2
            answer  = A.order;
            answer2 = A.order;
        otherwise
            answer  = A.order;
            answer2 = A.order;
            varargout = num2cell(ones(nargout -2, 1));
        end            
    case 2
        if (nargout > 1)
            error('packed:size:badopt', ...
            'Unknown command option.');
        end
        if (i < 1)
            error('packed:size:getdimarg:dimensionMustBePositiveInteger',...
                ['Dimension argument must be a positive integer scalar'...
                 ' in the range 1 to 2^31.']);
        elseif (i == 1 || i == 2)
            answer  = A.order;
        elseif (i > 2)
            answer = 1;
        end
    end
end

%!test
%! A = packed(eye(2,2));
%! myassert (ispacked(A));
%! myassert (size(A), [2, 2]);

%!test
%! A = packed([]);
%! myassert (ispacked(A));
%! myassert (size(A), [0, 0]);

%!test
%! A = packed;
%! myassert (ispacked(A));
%! myassert (size(A), [0, 0]);

%!error
%! A = packed;
%! myassert (ispacked(A));
%! size(A, 1, 2, 3);

%!test
%! A = packed([]);
%! myassert (ispacked(A));
%! [m, n] = size(A);
%! myassert ([m, n], [0, 0]);

%!test
%! A = packed(eye(4));
%! myassert (ispacked(A));
%! [m, n] = size(A);
%! myassert ([m, n], [4, 4]);

%!test
%! A = packed(eye(4));
%! myassert (ispacked(A));
%! [m, n, o, p] = size(A);
%! myassert ([m, n, o, p], [4, 4, 1, 1]);

%!test
%! A = packed;
%! size(A);
%! myassert (ans, [0, 0]);

%!error
%! lasterr('', '');
%! A = packed;
%! myassert (ispacked(A));
%! size(A, 0);

%!test
%! % size()
%! s = lasterror;
%! myassert (s.identifier, ...
%!     'packed:size:getdimarg:dimensionMustBePositiveInteger');

