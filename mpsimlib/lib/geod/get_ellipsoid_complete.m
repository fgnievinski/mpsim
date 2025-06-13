function ell2 = get_ellipsoid_complete (ell)
    ab2e = @(a,b) sqrt( (a^2 - b^2) / a^2 );
    ab2f = @(a,b) (a - b) / a;

    fn = fieldnames(ell);
    if all(ismember({'a','b'}, fn))
        a = ell.a;
        b = ell.b;
        e = ab2e(a, b);
        f = ab2f(a, b);
    elseif all(ismember({'a','e'}, fn))
        a = ell.a;
        e = ell.e;
        b = a*sqrt(1 - e^2);
        f = ab2f(a, b);
    elseif all(ismember({'a','f'}, fn))
        a = ell.a;
        f = ell.f;
        b = a*(1 - f);
        e = ab2e(a, b);
    else
        error('MATLAB:get_ellipsoid_complete:unkOption', ...
            'Not enough input.');
    end

    ell2.a = a;
    ell2.b = b;
    ell2.e = e;
    ell2.f = f;
    ell2.e_sq = e^2;
end

%!test
%! ell0 = get_ellipsoid();
%! ell1 = get_ellipsoid_complete(getfields(ell0, {'a','b'}));
%! ell2 = get_ellipsoid_complete(getfields(ell0, {'a','e'}));
%! ell3 = get_ellipsoid_complete(getfields(ell0, {'a','f'}));
%! ell0 = getfields(ell0, {'a','b','e','f','e_sq'});
%! %ell0, ell1, ell2, ell3  % DEBUG
%! myassert(struct2mat(ell1), struct2mat(ell0), -sqrt(eps()));
%! myassert(struct2mat(ell2), struct2mat(ell0), -sqrt(eps()));
%! myassert(struct2mat(ell3), struct2mat(ell0), -sqrt(eps()));

