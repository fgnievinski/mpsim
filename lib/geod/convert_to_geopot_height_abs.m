function [Z, geopot_diff, varargout] = convert_to_geopot_height_abs (pos_geod, method, opt)
%CONVERT_TO_GEOPOT_HEIGHT_ABS: Convert to geopotential height (absolute), given geodetic coordinates.

    if (nargin < 2) || isempty(method),  method = 'us fmh 3';  end
    g_c = getfield(get_meteo_const(), 'g_c');
    if isfieldempty(opt, 'N') || all(isnan(opt.N)),  opt.N = 0;  end
    switch lower(method)
    case 'ellipsoidal height'
        Z = pos_geod(:,3);
        geopot_diff = NaN(size(Z));
    case 'orthometric height'
        Z = pos_geod(:,3) - opt.N;
        geopot_diff = NaN(size(Z));
    case 'us fmh 3'
        [Z, varargout{1:nargout-2}] = convert_to_geopot_height1_fmh3 (...
            pos_geod, method, opt);
        geopot_diff = NaN(size(Z));
    otherwise
        pos_cart = convert_to_cartesian (pos_geod, opt.ell);
        pos_sph  = convert_to_spherical (pos_cart);
        [geopot_diff, varargout{1:nargout-2}] = get_geopot_diff (...
            pos_sph, method, opt);
        Z = geopot_diff ./ g_c;
    end
end

%%
function [Z, varargout] = convert_to_geopot_height1_fmh3 (pos_geod, method, opt) %#ok<INUSL>
    % Federal Meteorological Handbook No. 3 --
    % Rawinsonde and Pibal Observations
    % APPENDIX D (COMPUTATIONAL FORMULAE AND CONSTANTS),
    % section D.2 (Geopotential Height).
    % <http://www.ofcm.gov/fmh3/text/appendd.htm>
    N = opt.N;
    lat = pos_geod (:, 1);
    % gravity at latitude lat:
    g = 9.80616 ...
        .* ( 1-0.002637 .* cos(2*lat*pi/180) ...
            + 0.0000059 .* cos(2*lat*pi/180).^2 );
    % radius of the earth at latitude lat:
    pos_geod2 = pos_geod;  pos_geod2(:,3) = 0;
    pos_cart2 = convert_to_cartesian (pos_geod2, opt.ell);
    pos_sph2  = convert_to_spherical (pos_cart2);
    Re = pos_sph2 (:, 3) + N;
    % please note I add the geoidal undulation, so that
    % Re + ortho_height will give the radius at the height ortho_height.
    % gravity ratio:
    Gr = g .* Re ./ 9.80665;
    %       
    ell_height = pos_geod(:,3);
    ortho_height = ell_height - N;
    Z = ortho_height .* Gr ./ (ortho_height + Re);
    varargout = {Re, Gr};
    % Please note that:
    %   temp = convert_to_spherical(convert_to_cartesian(pos_geod, opt.ell));
    %   myassert((ortho_height + Re) == temp(:, 3));
    % which may lead you to think we don't need Re, only ortho_height + Re;
    % but actually Re is needed to obtain Gr.
end
        
%!shared
%! geoid_dir = 'c:\work\data\geoid\';
%! geopot_file = 'c:\work\data\geopot\egm96_to360.ascii';

%!test
%! out = convert_to_geopot_height_abs('methods');
%! myassert(iscell(out));
%! myassert(isvector(out));
%! myassert(all(cellfun(@ischar, out)));

%!test
%! if evalin('base', 'exist(''geoid'', ''var'')')
%!     geoid = evalin('base', 'geoid');
%! else
%!     geoid = setup_geoid (geoid_dir);
%! end
%! if evalin('base', 'exist(''coeff'', ''var'')')
%!     coeff = evalin('base', 'coeff');
%! else
%!     coeff = read_geopot_coeff (geopot_file);
%! end
%! ell = get_ellipsoid('wgs84');  % only one complete.
%! opt = struct('geoid',geoid, 'ell',ell, 'geopot_coeff',coeff);
%! 
%! pos_geod = rand_pt_geod;
%! 
%! methods = convert_to_geopot_height1('methods');
%! for i=1:length(methods)
%!    out =  convert_to_geopot_height1(pos_geod, methods{i}, opt);
%! end

