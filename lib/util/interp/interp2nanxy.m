function ZI = interp2nanxy (X,Y,Z,XI,YI,varargin)
    idx = ~isnan(XI) & ~isnan(YI);
    if all(idx)
        ZI = interp2(X,Y,Z,XI,YI,varargin{:});
    elseif none(idx)
        ZI = NaN(size(XI));
    else
        ZI = NaN(size(XI));
        ZI(idx) = interp2(X,Y,Z,XI(idx),YI(idx),varargin{:});
    end
end

%!shared
%! X = 1:3;
%! Y = 1:3;
%! Z = zeros(3,3);
%! XI = [2; 2;   NaN];
%! YI = [2; NaN; 2];
%! ZI = [0; NaN; NaN];

%!error
%! % interp2nanxy()
%! ZI2 = interp2 (X,Y,Z,XI,YI,'cubic');

%!test
%! ZI2 = interp2nanxy (X,Y,Z,XI,YI,'cubic');
%! %ZI, ZI2  % DEBUG
%! myassert(ZI2, ZI);

%!test
%! % just check it doesn't break:
%! ZI2 = interp2nanxy (X,Y,Z,NaN,NaN);

