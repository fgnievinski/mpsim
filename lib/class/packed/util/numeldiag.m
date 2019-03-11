function answer = numeldiag (A)
    switch nargin
    case 0
        error('packed:numeldiag:notEnoughInputs',...
        'Not enough input parameters.');
    case 1
        if isempty(A)
            answer = 0;
            return;
        elseif isscalar(A)
            error('packed:numeldiag:notSquare',...
            'numeltri() not defined for scalars.');
        elseif ~issquare(A)
            error('packed:numeldiag:notSquare',...
            'numeltri() not defined for not square matrices.');
        end
        [m, n] = size(A);
        myassert (m == n);
    otherwise
        error('packed:numeldiag:tooManyInputs',...
        'Too many input parameters.');
    end

    answer = n;
end

%!test
%! for i=1:10
%!     n = round(rand*100);
%!     if (n < 2),  continue;  end
%!     M = zeros(n);
%!     temp = diag(true(n));
%!     myassert( numeldiag(M), length(temp(:)) );
%!     myassert( numeldiag(M), length(temp(:)) );
%!     myassert( numeldiag(M), length(temp(:)) );
%! end

%!test
%! myassert(numeldiag ([]), 0);

%!error
%! numeldiag ()

%!error
%! numeldiag (1, 2)

%!error
%! numeldiag ([1])

%!error
%! numeldiag ([1 2 3; 4 5 6])

