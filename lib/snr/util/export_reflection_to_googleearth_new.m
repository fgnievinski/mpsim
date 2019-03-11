function export_reflection_to_googleearth_new (filepath, gps_pos_geod, ...
ffz_pos_local, refl_pos_local, circ_pos_local, circ_elev, color)
    if (nargin < 5),  circ_pos_local = [];  end
    if (nargin < 5),  color = 'r';  end
    function pos_geod = convert_from_local_cart2 (pos_local)
        [ignore, pos_geod] = convert_from_local_cart (pos_local, ...
            gps_pos_geod, ell);
    end
    if (size(ffz_pos_local,2) == 2),  ffz_pos_local(:,3) = 0;  end
    assert(size(gps_pos_geod,1) == 1)
    gps_pos_geod(2) = azimuth_range_negative_positive(gps_pos_geod(2));
    ell = get_ellipsoid('grs80');
        
    ffz_pos_geod = convert_from_local_cart2 ( ffz_pos_local);
    refl_pos_geod = convert_from_local_cart2 (refl_pos_local);
    circ_pos_geod = convert_from_local_cart2 (circ_pos_local);

    if nargin < 6
        gps_str = ge_point(gps_pos_geod(2), gps_pos_geod(1), 0, ...
            'altitudeMode','clampToGround', 'iconColor',ge_color('w',1), ...
            'name','', 'description','');
        doit = @(x, c) my_ge_plot(x(:,2), x(:,1), ...
            'lineWidth',3.0, 'lineColor',ge_color(c,1));
        ffz_str = doit( ffz_pos_geod, 'r');
        refl_str = doit(refl_pos_geod, 'g');
        circ_str = doit(circ_pos_geod, 'b');
        
        all_str = [circ_str, ffz_str, refl_str, gps_str];
        ge_output(filepath, all_str);
    else 
        gps_str = ge_point(gps_pos_geod(2), gps_pos_geod(1), 0, ...
            'altitudeMode','clampToGround', 'iconColor',ge_color('w',1), ...
            'name','', 'description','');
        doit = @(x, c) my_ge_plot(x(:,2), x(:,1), ...
            'lineWidth',2.0, 'lineColor',ge_color(c,1));
        ffz_str = doit( ffz_pos_geod, color);
        refl_str = [];
        circ_str = [];
        
        all_str = [circ_str, ffz_str, refl_str, gps_str];
        ge_output(filepath, all_str);
    end
end


%%
function varargout = my_ge_plot (x, y, varargin)
    if isempty(x) && isempty(y),  varargout = {[]};  return;  end
    [varargout{1:nargout}] = ge_plot (x, y, varargin{:});
end

%!test
%! temp = [...
%!      8   202
%!     15   203
%!     22   205
%!     29   207
%!     37   210
%!     45   213
%!     52   217
%!     60   223
%!     68   232
%!     75   245
%!     80   -86
%!     82   -32
%!     77     6
%!     71    24
%!     65    35
%!     58    43
%!     52    50
%!     46    57
%!     40    63
%!     34    69
%!     29    74
%!     24    80
%!     18    86
%!     13    91
%!      8    96
%! ];
%! elev = temp(:,1);
%! azim = temp(:,2);
%! height = 2;
%! 
%! wavelength = get_gps_const ('L2');
%! circ_elev = [1, 2, 3, 4, 5, 10, 15, 30];
%! circ_pos = get_specular_point (height, circ_elev);
%! refl_pos = get_specular_point (repmat(height, size(elev)), elev, azim);
%! ffz_pos = getfield(get_fresnel_zone(height, 5, azim(1), wavelength), 'pos');
%! gps_pos_geod = [40.130038 254.767209 1668.708];
%! 
%! filepath = [tempname '.kml'];
%! export_reflection_to_googleearth (filepath, gps_pos_geod, ffz_pos, refl_pos, circ_pos, circ_elev);
%! %eval(sprintf('!googleearth %s', filepath))
%! %delete(filepath)
%! disp(filepath)
%! winopen(filepath)

