function h = convert_from_geopot_height_rel (pos, method, opt)
%CONVERT_FROM_GEOPOT_HEIGHT_REL: Convert from geopotential height (relative to the geoid) -- and geodetic latitude and longitude --, to ellipsoidal height.

    %tol0 = sqrt(eps());  % too small to attain
    tol0 = nthroot(eps(), 3);
    if ~isfield(opt, 'tol') || isempty(opt.tol),  opt.tol = tol0;  end
    if ~isfield(opt, 'display') || isempty(opt.display),  opt.display = 'off';  end
    if ~isfield(opt, 'individually') || isempty(opt.individually),  opt.individually = false;  end
    if ~isfield(opt, 'approximate') || isempty(opt.approximate),  opt.approximate = true;  end
    %opt.simultaneously = false;  % DEBUG

    latlon = pos(:,1:2);
    Z = pos(:,3);
    h0 = Z;
    if opt.approximate && any(strcmpi(method, {'actual gravity','actual gravity, truncated'}))
        % try and get a faster better approximate solution:
        opt2 = opt;
        opt2.approximate = false;  % avoid infinite recursion.
        opt2.tol = 1;  % in meters
        h0 = convert_from_geopot_height_rel (pos, 'normal gravity, truncated', opt2);
    end

    if opt.individually
        f = @(h_i,i) convert_to_geopot_height_rel(horzcat(latlon(i,:), h_i), method, opt);
    else
        f = @(h) convert_to_geopot_height_rel(horzcat(latlon, h), method, opt);
    end

    opt.tol_abs = opt.tol;  % input tolerance is absolute.
    opt = rmfield(opt, 'tol');  % avoid misuse.
    if opt.individually
        normx = max(abs(h0));
        normy = max(abs(Z));
    else
        normx = norm(h0);
        normy = norm(Z);
    end
    opt.tolx_rel = opt.tol_abs ./ (1 + normx);  % inv_func2's tol are relative.
    opt.toly_rel = opt.tol_abs ./ (1 + normy);  % inv_func2's tol are relative.

    h = NaN(size(Z));
    %h = inv_func2(f, Z, h0, ...
    idx = ~isnan(Z);
    if none(idx),  return;  end
    h(idx) = inv_func2(f, Z(idx), h0, ...
        opt.tolx_rel, opt.toly_rel, opt.display, opt.individually);
end

%!test
%! %%
%! if ( evalin('base', 'exist(''geopot_coeff'', ''var'')') )
%!     geopot_coeff = evalin('base', 'geopot_coeff');
%! else
%!     %geopot_coeff_file = '../data/geopot/egm96';
%!     geopot_coeff_file = 'c:\Work\data\geopot\egm96_to360.ascii';
%!     warning('Trying to read geopotential coefficients from %s.', ...
%!         geopot_coeff_file);
%!     geopot_coeff = read_geopot_coeff (geopot_coeff_file);
%! end
%! if evalin('base', 'exist(''geoid'', ''var'')')
%!     geoid = evalin('base', 'geoid');
%! else
%!     %geoid_dir = '../data';
%!     geoid_dir = 'c:\Work\data\geoid\';
%!     warning('Trying to read geoid from %s.', geoid_dir);
%!     geoid = setup_geoid (geoid_dir);
%! end
%! ell = get_ellipsoid('wgs84');
%! opt = struct('geoid',geoid, 'ell',ell, 'geopot_coeff',geopot_coeff);
%! 
%! %%
%! n = ceil(10*rand);
%! pos_geod = rand_pos_geod(n);
%! latlon = pos_geod(:,1:2);
%! h = pos_geod(:,3);
%! opt.tol = sqrt(eps());
%! format long g
%! 
%! %%
%! opt.tol = sqrt(eps());
%! opt.tol = nthroot(eps(), 3);
%! %opt.tol = 1e-3;
%! %opt.tol = 1;
%! opt.individually = [];
%! %opt.individually = true;  % DEBUG
%! opt.display = 'iter';
%! %opt.display = '';
%! 
%! methods = convert_to_geopot_height_rel ('methods');
%! for i=1:length(methods)
%!     %disp(methods{i})  % DEBUG
%!     Z = convert_to_geopot_height_rel (pos_geod, methods{i}, opt);
%!     pos = horzcat(latlon, Z);
%!     h2 = convert_from_geopot_height_rel (pos, methods{i}, opt);
%!     %[h, h2, h2-h]  % DEBUG
%!     %[max(abs(h2-h)), opt.tol]  % DEBUG
%!     myassert(h2, h, -opt.tol)
%! end

