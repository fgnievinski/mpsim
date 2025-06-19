function dir = complete_direction (dir)
    assert(all(isfield(dir, {'azim','elev'})))
    assert(isvector(dir.azim) && isvector(dir.elev))
    n = numel(dir.elev);
    myassert(numel(dir.azim), n);
    dir.sph = [dir.elev, dir.azim, ones(n,1)];
    dir.cart = sph2cart_local(dir.sph);
end
