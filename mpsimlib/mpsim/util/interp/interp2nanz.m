function zi = interp2nanz (x, y, z, xi, yi, varargin)
    [z, idx] = zeronan(z);
    zi = interp2(x, y, z, xi, yi, varargin{:});
    idxi = interp2(x, y, idx, xi, yi, varargin{:});
    idxi = (idxi ~= 0);
    %idxi = (idxi >= 1);
    zi(idxi) = NaN;
end

%!shared
%! X = 1:4;
%! Y = 1:3;
%! Z = [NaN NaN NaN NaN;  NaN NaN 0 0;  NaN NaN 0 0];
%! XI = [1; 1.5; 2; 2.5];
%! YI = [1.5; 2.5; 2.5; 1.5];
%! ZI = [NaN; NaN; NaN; 0];

%!error
%! % interp2nanz()
%! ZI2 = interp2 (X,Y,Z,XI,YI,'spline');

%!test
%! ZI2 = interp2nanz (X,Y,Z,XI,YI,'spline');
%! %ZI, ZI2  % DEBUG
%! myassert(ZI2, ZI);

