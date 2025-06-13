function isc = is_contiguous (inp)
    isc = is_contiguous_elementwise (inp);
end

function isc = is_contiguous_elementwise (inp)
% see also: is_contiguous_vector
    assert(isvector(inp))
    n = numel(inp);
    ind = 1:n;
    ind_left  = ind - 1;  ind_left(1) = 1;
    ind_right = ind + 1;  ind_right(end) = n;
    isn = isnan(inp);
    isn_left  = isnan(inp(ind_left));
    isn_right = isnan(inp(ind_right));
    isc = ~isn & (~isn_left | ~isn_right);
end

%!test
%! inp = [1 2 3 4 5 NaN 7 NaN 9 0 NaN];
%! isc = [1 1 1 1 1  0  0  0  1 1  0 ];
%! isc2 = is_contiguous (inp);
%! [isc; isc2]  % DEBUG
%! myassert(isc2, isc)
