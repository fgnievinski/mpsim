function num = mydatemat (Num, algorithm)
%MYDATEMAT: Convert from Matlab's format (to internal epoch format).
% Intented to give more resolution to epoch units, for near-current epochs.

    if (nargin < 2) || isempty(algorithm),  algorithm = 'rigorous';  end
    switch lower(algorithm)
    case 'faster'
        [factor0, Num0] = mydatebase (false);
        num = (Num - Num0) .* factor0;
    case 'rigorous'
        vec = datevec(Num);
        num = mydatenum (vec);
    otherwise
        error('MATLAB:mydatemat:unkAlgo', ...
            'Unknown algorithm "%s".', char(algorithm));
    end
end

%!test
%! myassert(mydatemat(datenum([2000 1 1])), 0);
%! myassert(mydatemat(datenum([2000 1 1  0 0 0])), 0);
%! myassert(mydatemat(datenum([1999 12 31  0 0 0])), -86400);
%! myassert(mydatemat(datenum([2000 1 1  0 0 1])), 1, -sqrt(eps()));
%! myassert(mydatemat(datenum([2000 1 1  0 0 1]), 'faster'), 1, -nthroot(eps(), 3));  % lower precision

