function R = get_rotation_matrix5_local (dir_nrml)
    if ~isfield(dir_nrml, 'azim') || isempty(dir_nrml.azim)
        temp = cart2sph_local(dir_nrml.cart);
        dir_nrml.azim = temp(:,2);
    end
    dir_up_cart = [0 0 1];
    %Ra = get_rotation_matrix2_local (dir_up_cart, dir_nrml.cart, true);  % WRONG!
    Ra = get_rotation_matrix2_local (dir_nrml.cart, dir_up_cart, true);
    %Rb = get_rotation_matrix_local (3, +dir_nrml.azim);  % WRONG!
    Rb = get_rotation_matrix_local (3, -dir_nrml.azim);
    %R = frontal_mtimes(Ra, Rb);  % WRONG!
    R = frontal_mtimes(Rb, Ra);
end

%!test
%! % two normal directions sharing the same slope but with different aspect.
%! % two user directions having the azimuth of their respective normals.
%! %rand('seed',0)
%! slope = randint(0, 90);
%! azim2 = randint(0, 360);
%! %azim2 = 0  % DEBUG
%! %azim2 = 45  % DEBUG
%! dir_nrml1.elev = slope;
%! dir_nrml2.elev = slope;
%! dir_nrml1.azim = 0;
%! dir_nrml2.azim = azim2;
%! dir_user1.azim = dir_nrml1.azim;
%! dir_user2.azim = dir_nrml2.azim;
%! %dir_user1.elev = randint(-90, +90);
%! dir_user1.elev = randint(-90+slope, +slope);
%! dir_user2.elev = dir_user1.elev;
%! 
%! function dir = completeit (dir)
%!     dir.sph = [dir.elev, dir.azim, 1];
%!     dir.cart = sph2cart_local(dir.sph);
%! end
%! dir_nrml1 = completeit(dir_nrml1);
%! dir_nrml2 = completeit(dir_nrml2);
%! dir_user1 = completeit(dir_user1);
%! dir_user2 = completeit(dir_user2);
%! 
%! R1 = get_rotation_matrix5_local (dir_nrml1);
%! R2 = get_rotation_matrix5_local (dir_nrml2);
%! 
%! dir_user1b.cart = (R1 * dir_user1.cart.').';
%! dir_user2b.cart = (R2 * dir_user2.cart.').';
%! function dir = completeit2 (dir)
%!     dir.sph = cart2sph_local(dir.cart);
%!     dir.elev = dir.sph(:,1);
%!     dir.azim = dir.sph(:,2);
%! end
%! dir_user1b = completeit2(dir_user1b);
%! dir_user2b = completeit2(dir_user2b);
%! 
%! dir_user1c.elev = dir_user1.elev - (dir_nrml1.elev - 90);
%! dir_user1c.azim = 0;
%! dir_user2c = dir_user1c;
%! 
%! %[dir_nrml1.elev, dir_user1.elev, dir_user1b.elev, dir_user1c.elev]  % DEBUG
%! %[dir_nrml2.elev, dir_user2.elev, dir_user2b.elev, dir_user2c.elev]  % DEBUG
%! %[dir_nrml1.azim, dir_user1.azim, dir_user1b.azim, dir_user1c.azim]  % DEBUG
%! %[dir_nrml2.azim, dir_user2.azim, dir_user2b.azim, dir_user2c.azim]  % DEBUG
%! myassert(dir_user1b.elev, dir_user1c.elev, -sqrt(eps()))
%! myassert(dir_user2b.elev, dir_user2c.elev, -sqrt(eps()))
%! myassert(dir_user1b.azim, dir_user1c.azim, -sqrt(eps()))
%! myassert(dir_user2b.azim, dir_user2c.azim, -sqrt(eps()))
%! %disp('hw!')

%!test
%! % general case.
%! slope = randint(0, 90);
%! azim  = randint(0, 360);
%! dir_nrml.elev = slope;
%! dir_nrml.azim = 0;
%! dir_user.azim = dir_nrml.azim;
%! %dir_user.elev = randint(-90, +90);
%! dir_user.elev = randint(-90+slope, +slope);
%! 
%! function dir = completeit (dir)
%!     dir.sph = [dir.elev, dir.azim, 1];
%!     dir.cart = sph2cart_local(dir.sph);
%! end
%! dir_nrml = completeit(dir_nrml);
%! dir_user = completeit(dir_user);
%! 
%! R = get_rotation_matrix5_local (dir_nrml);
%! 
%! dir_userb.cart = (R * dir_user.cart.').';
%! function dir = completeit2 (dir)
%!     dir.sph = cart2sph_local(dir.cart);
%!     dir.elev = dir.sph(:,1);
%!     dir.azim = dir.sph(:,2);
%! end
%! dir_userb = completeit2(dir_userb);
%! 
%! dir_userc.elev = 90 - acosd(dot(dir_user.cart, dir_nrml.cart));
%! dir_userc.azim = NaN;
%! 
%! %[dir_nrml.elev, dir_user.elev, dir_userb.elev, dir_userc.elev]  % DEBUG
%! %[dir_nrml.azim, dir_user.azim, dir_userb.azim, dir_userc.azim]  % DEBUG
%! myassert(dir_userb.elev, dir_userc.elev, -sqrt(eps()))
%! %TODO: test azimuth in the general case.

%!test
%! % horizontal surface 
%! R = get_rotation_matrix5_local(struct('cart',[0 0 1], 'azim',0));
%! myassert(R, eye(3), -sqrt(eps()))

