function azimu = azimuth_unique (azim)
    azim_original = azim;
    azim = azim(:);
    x = sind(azim);  y = cosd(azim);
    xy = [x, y];
    xyu = unique(xy, 'rows');
    xu = xyu(:,1);
    yu = xyu(:,2);
    azimu = 180/pi * atan2(xu, yu);
    if all(azim_original >= 0),  azimu = azimuth_range_positive(azimu);  end
    azimu = sort(azimu);
end

%!test
%! in = [...
%!   -180
%!    -90
%!      0
%!     90
%!    180
%! ];
%! out = [...
%!   -180
%!    -90
%!      0
%!     90
%! ];
%! out2 = azimuth_unique (in);
%! myassert(out2, out)

