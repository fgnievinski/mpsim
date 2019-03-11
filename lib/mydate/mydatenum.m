function num = mydatenum (vec, is_diff)
%MYDATENUM: Convert from vector parts (to internal epoch format).
% Intented to give more resolution to epoch units, for near-current epochs.
    if (nargin < 2),  is_diff = [];  end
    m = size(vec,2);
    if isempty(vec)
        num = vec;
        return;
    end
    if (m > 6)
        error('MATLAB:mydatenum:inputError', ...
            'Input must have fewer than 6 columns.');
    end
    % fill-in missing columns with zeros:
    vec(:,(end+1):6) = 0;
    if any( ~(0 <= vec(:,2) & vec(:,2) <= 12) & ~isnan(vec(:,2)) )
        warning('MATLAB:mydatenum:monthRange', 'Invalid month range.');
    end
        
%     % WRONG! loses precision.
%     [factor0, Num0] = mydatebase (is_diff);
%     Num = datenum(vec);
%     num = (Num - Num0) .* factor0;
    
    % do it separately for large and small offset parts:
    [factor0, Num0, dNum0, dyear0] = mydatebase (is_diff); %#ok<ASGLU>
    vec2 = vec;  vec2(:,1) = vec2(:,1) - dyear0;
    %Num2 = datenum(vec2);
    %if ~any(isnan(vec2(:)))
    %    Num2 = datenum(vec2);
    %else
    %    cell = mat2cellcol(vec2);  % split up columns for Y, M, D, h, m, s.
    %    Num2 = datenum(cell{:});
    %end
    % safer input format (with, e.g., [847335 0 0  0 0 0]:
    cell = mat2cellcol(vec2);  % split up columns for Y, M, D, h, m, s.
    Num2 = datenum(cell{:});
    Num = Num2 - dNum0;
    num = Num * factor0;
end

%!test
%! in = NaN(2,6);
%! out = NaN(2,1);
%! out2 = mydatenum(in);
%! myassert(isequaln(out2, out))

%!test
%! myassert(mydatenum ([2000 1 1]), 0);
%! myassert(mydatenum ([2000 1 1  0 0 0]), 0);
%! myassert(mydatenum ([1999 12 31  0 0 0]), -86400);
%! myassert(mydatenum ([2000 1 1  0 0 1]), 1, -sqrt(eps()));
%! myassert(mydatenum ([0 0 0  0 0 1], true), 1, -sqrt(eps()));
%! myassert(mydatenum ([0 0 0  1 0 0], true), 3600, -sqrt(eps()));
%! myassert(mydatenum ([0 0 1  0 0 0], true), 3600*24, -sqrt(eps()));

%!test
%! % mydatenum()
%! myassert(mydatevec (0), [2000 1 1  0 0 0], 0);
%! myassert(mydatevec (0), [2000 1 1  0 0 0], 0);
%! myassert(mydatevec (-86400), [1999 12 31  0 0 0]);
%! myassert(mydatevec (1), [2000 1 1  0 0 1], -sqrt(eps()));
%! myassert(mydatevec (1, true), [0 0 0  0 0 1], -sqrt(eps()));
%! myassert(mydatevec (3600, true), [0 0 0  1 0 0], -sqrt(eps()));
%! myassert(mydatevec (3600*24, true), [0 1 1  0 0 0], -sqrt(eps()));

%!test
%! myassert(isempty(mydatenum(zeros(1,0))))
