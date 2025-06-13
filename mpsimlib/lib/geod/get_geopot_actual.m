function answer = get_geopot_actual (pos_sph, ell, geopot_coeff, n_max, ...
get_unique_P, cache_P)
%GET_GEOPOT_ACTUAL: Return the actual geopotential, given a position in global spherical -- NOT GEODETIC -- coordinates.

    if isempty(pos_sph),  answer = zeros(0,1);  return;  end
    if (nargin < 4) || isempty(n_max),  n_max = 360;  end
    if (nargin < 5),  get_unique_P = [];  end
    if (nargin < 6),  cache_P = [];  end
    if any(pos_sph(:, 3) < ell.a/2)
        warning ('geodesy:get_geopot:badCoord', ...
          ['It seems you are passing height instead of radius. '...
           'Spherical coordinates should be latitude, longitude, and radius.']);
    end
    
    answer = get_centrifugal_potential (pos_sph, ell) ...
           + get_gravitation_potential (pos_sph, ell, geopot_coeff, n_max, ...
               get_unique_P, cache_P);
end

function answer = get_centrifugal_potential (pos_sph, ell)
    lat_sph = pos_sph (:, 1) * pi/180;
    r = pos_sph (:, 3);

    p = r .* cos(lat_sph);
    answer = (1/2) * (ell.omega .* p).^2;
end

function V = get_gravitation_potential (pos_sph, ell, geopot_coeff, n_max, ...
get_unique_P, cache_P)
    %get_unique_P = false;  % DEBUG
    %cache_P = false;  % DEBUG
    myassert(n_max <= 360);
    %n_max

    % The formula used here and the definition of the normalization implied
    % are described in
    %   NIMA Technical Report TR8350.2, "Department of Defense World 
    % Geodetic System 1984, Its Definition and Relationships With 
    % Local Geodetic Systems", Third Edition, 4 July 1997, available at
    % <ftp://164.214.2.65/pub/gig/tr8350.2/wgs84fin.pdf>,
    % printed pages 5-2 and 5-3, PDF p. 51-52.
    
    GM = ell.GM;
    a = ell.a;
    
    num_pts = size(pos_sph, 1);
    num_n = n_max + 1;
    m_max = n_max;
    num_m = m_max + 1;
    all_n = (0:n_max)';
    myassert(isequal( size(all_n), [num_n, 1] ));
    all_m = 0:m_max;
    myassert(isequal( size(all_m), [1, num_m] ));
    
    V = zeros(num_pts, 1);

    lat_sph = pos_sph (:,1);
    lon     = pos_sph (:,2);
    r       = pos_sph (:,3);
    sin_lat_sph = sind(lat_sph);

    all_C = geopot_coeff.C (0+1:n_max+1, 0+1:m_max+1);
    all_S = geopot_coeff.S (0+1:n_max+1, 0+1:m_max+1);
    all_C = full(all_C);
    all_S = full(all_S);
    get_all_P (n_max, get_unique_P, cache_P, sin_lat_sph);
    for i=1:num_pts
        all_P = get_all_P (n_max, get_unique_P, cache_P, sin_lat_sph, i);
        myassert(size(all_P), [num_n, num_m]);
        
        all_cos_mlon = cosd(all_m.*lon(i));
        all_sin_mlon = sind(all_m.*lon(i));
        all_a_r_ratio = (a/r(i)).^all_n;

        %all_cos_mlon = repmat(all_cos_mlon, num_n, 1);
        %all_sin_mlon = repmat(all_sin_mlon, num_n, 1);
        %all_a_r_ratio = repmat(all_a_r_ratio, 1, num_m);
        %temp =   all_C .* all_cos_mlon ...
        %       + all_S .* all_sin_mlon;
        %temp2 = all_P .* temp;
        %all_prod = all_a_r_ratio .* temp2;
        temp = bsxfun(@times, all_C, all_cos_mlon) ...
             + bsxfun(@times, all_S, all_sin_mlon);
        temp2 = all_P .* temp;
        all_prod = bsxfun(@times, all_a_r_ratio, temp2);
        %myassert(issparse(temp));
        %myassert(issparse(all_prod));

        V(i) = (GM/r(i)) * (1 + sum(sum(all_prod)));
    end
end

function all_P = get_all_P (n_max, get_unique_P, cache_P, sin_lat_sph, i)
    if isempty(get_unique_P),  get_unique_P = true;  end
    if isempty(cache_P),  cache_P = true;  end
    persistent all_P_u sin_lat_sph_u indu
    persistent sin_lat_sph_old is_input_unique
    if ~isempty(is_input_unique) && is_input_unique,  get_unique_P = false;  end  % not worth it.
    if (nargout < 1) || (nargin < 5) || isempty(i)  % init only.
        if ~get_unique_P,  return;  end
        if ~cache_P || ~isequaln(sin_lat_sph, sin_lat_sph_old)
            if ~isempty(all_P_u) && ~isempty(is_input_unique) && ~is_input_unique
                %warning('MATLAB:get_geopot:cacheClear', 'Cache cleared.');
            end
            all_P_u = [];
        end
        if isempty(all_P_u)
            [is_input_unique, sin_lat_sph_u, ignore, indu] = is_unique(sin_lat_sph); %#ok<ASGLU>
            if is_input_unique,  return;  end
            all_P_u = get_legendre_normal_assoc_func (n_max, sin_lat_sph_u);
            sin_lat_sph_old = sin_lat_sph;
        end
        return;
    end
    if ~get_unique_P
        all_P = get_legendre_normal_assoc_func (n_max, sin_lat_sph(i));
        return;
    end
    all_P = all_P_u(:,:,indu(i));
end

%!test
%! % The geopotential on the geoid should be W_0.
%! 
%! if ( evalin('base', 'exist(''geopot_coeff'', ''var'')') )
%!     geopot_coeff = evalin('base', 'geopot_coeff');
%! else
%!     geopot_coeff_file = '../data/geopot/egm96';
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
%!
%! %keyboard
%! 
%! 
%! % value used to compute N from the EGM96 harmonic coefficients:
%! W_0 = 62636856.88;  % m^2 s^2
%! % Accordingly to eq. (11.2-3) in Chapter 11, "The EGM96 Geoid Undulation 
%! % With Respect to the WGS84 Ellipsoid", of the following publication:
%! % The Development of the Joint NASA GSFC and NIMA Geopotential Model EGM96,
%! % F. G. Lemoine, S. C. Kenyon, J. K. Factor, R.G. Trimmer, N. K. Pavlis, 
%! % D. S. Chinn, C. M. Cox, S. M. Klosko, S. B. Luthcke, M. H. Torrence, 
%! % Y. M. Wang, R. G. Williamson, E. C. Pavlis, R. H. Rapp and T. R. Olson, 
%! % NASA Goddard Space Flight Center, Greenbelt, Maryland, 20771 USA,
%! % July 1998. Available at:
%! % <http://cddis.gsfc.nasa.gov/926/egm96/doc/S11.HTML>
%! 
%! n = 10;
%! n = 15;
%! [lon, lat] = meshgrid(linspace(-180, +180, n), linspace(-90, +90, n));
%! siz = size(lon);
%! 
%! latlon = [lat(:) lon(:)];
%! N = reshape(get_geoidal_undulation(latlon, geoid), siz);
%! %figure, imagesc(lon(1,:), lat(:,1), N), set(gca, 'ydir', 'normal')
%! 
%! 
%! pos_geod = [latlon N(:)];
%! %pos_geod = single(pos_geod);  % DEBUG
%! pos_cart = convert_to_cartesian (pos_geod, ell);
%! pos_sph  = convert_to_spherical (pos_cart);
%! 
%! get_geopot(pos_sph(1,:), ell, geopot_coeff);  % mess with cache.
%! W = reshape(get_geopot(pos_sph, ell, geopot_coeff), siz);
%! W_err = W - W_0;
%!
%! % Mean normal gravity (given in Moritz, The GRS80, p. 131),
%! % on the ellipsoid GRS80, not WGS84.
%! % It's used only to scale the geopotential in meters:
%! g_normal_mean = 9.797644656;  % m/s^2
%! 
%! figure
%! imagesc(lon(1,:), lat(:,1), W_err/g_normal_mean)
%! axis image
%! set(gca, 'ydir', 'normal')
%! title('[ W(h=N) - W_0 ] / \gamma')
%! colorbar
%! colormap(flipud(gray))
%! 
%! tol = 0.05;  % metres
%! % The computation of N for the EGM96 included a term which is 
%! % described in the following paper:
%! %    R. H. Rapp, Use of potential coefficient models for geoid undulation 
%! % determinations using a spherical harmonic representation of the height
%! % anomaly/geoid undulation difference, Journal of Geodesy, Volume 71, 
%! % Issue 5, Apr 1997, Pages 282 - 289.
%! %    Fig. 1 on p. 285 resembles closely the discrepancies that we found 
%! % between W on the geoid (which is given by Rapp et al. elsewhere) 
%! % and W_0. Due to this similarity, I atribute the discrepancies we
%! % found here to the introduction of that term. It's weird, because
%! % if my interpretation is correct, that term makes the geoid not 
%! % coincide with the geopotential level surface W=W_0, as given in its
%! % spherical harmonic expansion. I thought that was the very definition 
%! % of geoid. I doubt my interpretation, but I trust my calculations.
%! %    Rapp gives a figure, -3.4 m, which we will use here for the 
%! % maximum allowable discrepancy.
%! 
%! %max(max(abs(W_err))) / g_normal_mean
%! myassert ( max(max(abs(W_err))) / g_normal_mean < 3.4+0.05 );
