function vec = mydatevec (num, is_diff, algorithm)
%MYDATEVEC: Convert epoch to vector parts.
    if (nargin < 2),  is_diff = [];  end
    if (nargin < 3) || isempty(algorithm),  algorithm = 1;  end

    switch algorithm
    case 1
        [factor0, Num0] = mydatebase (is_diff);
        Num = num ./ factor0 + Num0;
        vec = datevec(Num);
    case 2
        [factor0, Num0, dNum0, dyear0] = mydatebase (is_diff); %#ok<ASGLU>
        Num2 = num ./ factor0 + dNum0;
        vec2 = datevec (Num2);
        vec = vec2;  vec(:,1) = vec(:,1) + dyear0;
    end
end

%!test
%! % mydatevec()
%! test mydatenum
