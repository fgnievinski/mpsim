function answer = get_geoidal_undulation (pos, geoid, interp_method)
%GET_GEOIDAL_UNDULATION: Return the geoidal undulation at a given geodetic position.

    if (nargin < 3) || isempty(interp_method),  interp_method = 'linear';  end
    %interp_method  % DEBUG
    
    lat = pos(:, 1);
    lon = pos(:, 2);

    % The geoid grid is distributed with longitude
    % ranging from 0 to +360 degrees.
    lon = angle_range_positive(lon);

    %if strcmp(interp_method, 'linear') && exist('interp2_linear_c', 'file')
    try
        answer = interp2_linear_c (...
            geoid.info.lon_domain, geoid.info.lat_domain, geoid.data, ...
            double(lon), double(lat));
    catch
        if ~is_octave(),  interp_method = ['*' interp_method];  end
        answer = interp2 (...
            geoid.info.lon_domain, geoid.info.lat_domain, geoid.data, ...
            lon, lat, interp_method, NaN);
    end

    if any(isnan(answer))
        error ('Position out of geoid bounds.');
    end
end


%!shared
%! %geoid_dir = '../data/geoid';
%! geoid_dir = 'D:\Felipe-old\ray_tracer-data\geoid\';
%! 
%! if evalin('base', 'exist(''geoid'', ''var'')')
%!     geoid = evalin('base', 'geoid');
%! else
%!     if evalin('base', 'exist(''geoid_dir'', ''var'')')
%!         geoid_dir = evalin('base', 'geoid_dir');
%!     end
%!     warning('Trying to read geoid from %s.', geoid_dir);
%!     geoid = setup_geoid (geoid_dir);
%! end

%!test
%! % This test dataset is provided directly at:
%! %   <http://earth-info.nga.mil/GandG/wgsegm/readme.txt>
%! % or following the links at
%! %   <http://earth-info.nga.mil/GandG/wgsegm/egm96.html>
%! geoid_test = [
%!      38.6281550   269.7791550     -31.628 ;
%!     -14.6212170   305.0211140      -2.969 ;
%!      46.8743190   102.4487290     -43.575 ;
%!     -23.6174460   133.8747120      15.871 ;
%!      38.6254730   359.9995000      50.066 ;
%!       -.4667440      .0023000      17.329 ;
%! ];
%!
%! % those longitude coordinates run from 0 to 360,
%! % but this function requires lon between -180 and +180:
%! idx = geoid_test(:,2) > 180;
%! geoid_test(idx, 2) = geoid_test(idx, 2) - 360;
%! clear idx
%! 
%! % The only way to interpolate within an error of 
%! % half the least significant digit in the known answers (0.0005)
%! % is using spline interpolation, which is terribly expensive.
%! % Here we'll use instead with linear interpolation, which for the 
%! % test cases are good within geoid_tol:
%! geoid_tol = 0.06;
%! answer = get_geoidal_undulation (geoid_test(:, 1:2), geoid);
%! myassert(geoid_test(:, 3), answer, -geoid_tol);

%!test
%! % Catch an error w.r.t. longitudes
%! lat = 0;
%! lon = -50;
%! N_correct = -25.69;  % m, 
%! % given by NGA EGM96 Geoid Calculator
%! % <http://earth-info.nga.mil/GandG/wgsegm/intpt.html?>
%! 
%! N = get_geoidal_undulation ([lat, lon], geoid);
%! 
%! geoid_tol = 0.06;
%! myassert(N, N_correct, -geoid_tol);

%!test
%! % get_geoidal_undulation
%! coast = load('coast');
%! coast.lon = coast.long;
%! figure
%! imagesc(geoid.info.lon_domain, geoid.info.lat_domain, geoid.data)
%! set(gca(), 'YDir','normal')
%! hold on
%! plot(angle_range_positive(coast.lon), coast.lat, '.k')
