function pos_cart = convert_to_cartesian_from_spherical (pos_sph)
    pos_cart = convert_from_spherical (pos_sph);
end

%!test
%! pos_sph = rand(1,3);
%! pos_cart  = convert_from_spherical (pos_sph);
%! pos_cart2 = convert_to_cartesian_from_spherical (pos_sph);
%! myassert(pos_cart2, pos_cart)

