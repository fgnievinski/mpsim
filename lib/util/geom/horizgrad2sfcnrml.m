function [dir_nrml, vec_nrml] = horizgrad2sfcnrml (varargin)
    switch nargin
    case 1
        horiz_grad = varargin{1};
    case 2
        dz_dx = varargin{1};
        dz_dy = varargin{2};
        horiz_grad = [dz_dx(:), dz_dy(:)];
        horiz_grad = xyz2neu(horiz_grad);
    end
    vec_nrml = [-horiz_grad, ones(size(horiz_grad,1),1)];
    dir_nrml = normalize_vec(vec_nrml);
end

%!test
%! temp = [...
%!     0   -1  45    0;
%!     0   +1  45  180;
%!    -1    0  45   90;
%!    +1    0  45  270;
%!     0    0  90    0;
%! ];
%! horiz_grad = xyz2neu(temp(:,1:2));
%! dir_nrml.sph = temp(:,3:end);  dir_nrml.sph(:,3) = 1;
%! dir_nrml2.cart = horizgrad2sfcnrml (horiz_grad);
%! horiz_grad2 = sfcnrml2horizgrad (dir_nrml2.cart);
%! dir_nrml2.sph = cart2sph_local(dir_nrml2.cart);
%!   %%whos horiz_grad horiz_grad2
%!   %[dir_nrml.sph, dir_nrml2.sph, dir_nrml2.sph-dir_nrml.sph]
%!   %[horiz_grad, horiz_grad2, horiz_grad2-horiz_grad]
%! myassert(azimuth_diff(dir_nrml2.sph, dir_nrml.sph), 0, -sqrt(eps()))
%! myassert(horiz_grad2, horiz_grad, -sqrt(eps()))

