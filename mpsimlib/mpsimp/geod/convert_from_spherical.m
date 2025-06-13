function pos_cart = convert_from_spherical (pos_sph)
%CONVERT_FROM_SPHERICAL: Convert from global spherical coordinates, to global Cartesian coordinates.

    if isempty(pos_sph),  pos_cart = pos_sph;  return;  end
    pos_sph(:,end+1:3) = 1;
    [x, y, z] = sph2cart (...
        pos_sph(:,2)*pi/180, pos_sph(:,1)*pi/180, pos_sph(:,3));
    pos_cart = [x y z];
end

%!test
%! pos_sph = [90 0 1];
%! myassert([0 0 1], convert_from_spherical (pos_sph), -eps);

%!test
%! pos_sph = [-90 0 1];
%! myassert([0 0 -1], convert_from_spherical (pos_sph), -eps);

%!test
%! pos_sph = [0 0 1];
%! myassert([1 0 0], convert_from_spherical (pos_sph), -eps);

%!test
%! pos_sph = [0 180 1];
%! convert_from_spherical (pos_sph);
%! myassert([-1 0 0], convert_from_spherical (pos_sph), -eps);

%!test
%! pos_sph = [0 -180 1];
%! myassert([-1 0 0], convert_from_spherical (pos_sph), -eps);

%!test
%! pos_sph = [0 90 1];
%! %convert_from_spherical (pos_sph);
%! myassert([0 1 0], convert_from_spherical (pos_sph), -eps);

%!test
%! pos_sph = [0 -90 1];
%! myassert([0 -1 0], convert_from_spherical (pos_sph), -eps);

%!test
%! pos_sph = [0 45 1];
%! temp = convert_from_spherical (pos_sph);
%! %temp, temp - [sqrt(1/2) sqrt(1/2) 0]
%! myassert([sqrt(1/2) sqrt(1/2) 0], convert_from_spherical (pos_sph), -eps);

