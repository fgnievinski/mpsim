%! % economic transformation -- when all we need is grazing angle.
function dir2 = snr_fwd_direction_local2sfc_grazing (dir_local, dir_normal_cart)
    if isfieldempty(dir_local, 'cart')
        n = numel(dir_local.elev);
        dir_local.sph  = [dir_local.elev, dir_local.azim, ones(n,1)];
        dir_local.cart = sph2cart_local (dir_local.sph);
    end
    graz = convert_dir_local2sfc_grazing (dir_local.cart, dir_normal_cart);
    dir2.graz = graz;
    dir2.elev = graz;
    n = size(dir_local.cart,1);
    dir2.azim = NaN(n,1);
    dir2.sph  = NaN(n,3);  dir2.sph(:,1) = dir2.elev;
    dir2.cart = NaN(n,3);
end

%!test
%! % snr_fwd_direction_local2sfc_grazing()
%! test('snr_fwd_direction_local2')

