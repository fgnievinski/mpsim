function [dir_nrml_cart, dir_nrml, siz] = slopeaspect2sfcnrml (slope, aspect)
    siz = size(slope);  myassert(size(aspect), siz);  n = prod(siz);
    slope  = reshape(slope,  [n,1]);
    aspect = reshape(aspect, [n,1]);

    dir_nrml.elev = 90 - slope;
    dir_nrml.azim = aspect;
    dir_nrml.sph(:,1) = dir_nrml.elev;
    dir_nrml.sph(:,2) = dir_nrml.azim;
    dir_nrml.sph(:,3) = 1;
    dir_nrml.cart = sph2cart_local(dir_nrml.sph);

    dir_nrml_cart = dir_nrml.cart;
end

%!test
%! test('horizgrad2slopeaspect')

