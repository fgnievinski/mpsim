function [dz_dx, dz_dy, dir_nrml] = slopeaspect2horizgrad (slope, aspect)
    [ignore, dir_nrml, siz] = slopeaspect2sfcnrml (slope, aspect); %#ok<ASGLU>
    [dz_dx, dz_dy] = sfcnrml2horizgrad (dir_nrml.cart);
    dz_dx = reshape(dz_dx, siz);
    dz_dy = reshape(dz_dy, siz);
end

%!test
%! test('horizgrad2slopeaspect')

