%EXTRAP1NN: nearest-neighbor extrapolation.
function yi = extrap1nn (x, y, xi, yi, dir)
    switch dir
    case 'above'
        [xl, ind] = max(x);
        yi(xi > xl) = y(ind);
    case 'below'
        [xl, ind] = min(x);
        yi(xi < xl) = y(ind);
    case 'both'
        yi = extrap1nn (x, y, xi, yi, 'above');
        yi = extrap1nn (x, y, xi, yi, 'below');
    end
end 

%!test
%! yi = extrap1nn (1:5, (1:5)*2, 0:6, NaN(1,7), 'both');
%! myassert(yi, [1*2 NaN(1,5) 5*2])
