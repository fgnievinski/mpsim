function [cov_polar, std_polar, r, a] = azimuth_cov_cart2polar (cov_cart, x, y)
    n = numel(x);
    assert(numel(y) == n)
    assert(isvector(x))
    assert(isvector(y))
    siz = size(x);
    x = reshape(x, [1 1 n]);
    y = reshape(y, [1 1 n]);
    rsq = x.^2 + y.^2;
    r = sqrt(rsq);
    dr_dxy = divide_all([x, y], r);
    da_dxy = 180/pi * divide_all([y, -x], rsq);
    dra_dxy = [dr_dxy; da_dxy];
    [temp{1:min(nargout,2)}] = frontal_propagate_cov (cov_cart, dra_dxy);
    if isscalar(temp),  temp{2} = [];  end
    [cov_polar, std_polar] = temp{:};
    r = reshape(r, siz);
    if (nargout < 4),  return;  end
    a = azimuth_aux (x, y);
    a = reshape(a, siz);
end

% subsx = @(u,w0,w0str) feval(symengine,'subsex',u,[char(w0) '=' w0str]);
% syms x y real
% r = sqrt(x^2 + y^2)
% a = atan(x/y)
% mydiff = @(arg) [diff(arg, x), diff(arg, y)];
% mydiff = @(arg) subsx(mydiff(arg), r, 'r'); 
% dr_dxy = mydiff(r)
% da_dxy = mydiff(a)
% da_dxy = simple(da_dxy * r^2) ./ sym('r^2')
% % dr_dxy = [ x/r, y/r]
% % da_dxy = [ y/r^2, -x/r^2]
% dra_dxy = [dr_dxy; da_dxy]
% % [   x/r,    y/r]
% % [ y/r^2, -x/r^2]
% r_dra_dxy = dra_dxy .* sym('r')
% % [   x,    y]
% % [ y/r, -x/r]
 
