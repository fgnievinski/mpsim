function ind = randroundunique (n, max, min)
    if (nargin < 3),  min = 1;  end
    if (min > max)
        temp = min;
        min = max;
        max = temp;
    end
    %max, min  % DEBUG
    if (n > (max - min + 1))
        error('MATLAB:randroundunique:tooMany', ...
        'There are not enough unique integer numbers within the inteval.');
    end

    ind = [];
    while (length(ind) < n)
        %disp('hw!')  % DEBUG
        p = n - length(ind);
        ind = unique([ind; round(randint(min, max, p, 1))]);
    end
end

%!error
%! ind = randroundunique (100, 1, 10);

%!test
%! % randroundunique ()
%! s = lasterror;
%! myassert(s.identifier, 'MATLAB:randroundunique:tooMany')

%!test
%! ind = randroundunique (10, 100, 1);
%! myassert(length(unique(ind)), 10)
%! myassert(all( 1 <= ind & ind <= 100 ))

%!test
%! ind = randroundunique (100, 100, 1)
%! myassert(length(unique(ind)), 100)
%! myassert(all( 1 <= ind & ind <= 100 ))

