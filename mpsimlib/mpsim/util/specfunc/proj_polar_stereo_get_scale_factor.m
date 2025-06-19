function proj2 = proj_polar_stereo_get_scale_factor (proj)
% Formulas given in the following publication:
%   Snyder, John Parr (1987), Map projections--a working manual
%   Washington. 383 p. (U.S. Geological Survey professional paper 1395)
%
% All equations are in p. 161 of that publication.
% For the main equations I give the eq. number as used in the 
% original publication.

    %%
    % I use the same data structure for map information
    % as used by MAtlab's Mapping Toolbox:
    lat_ts = proj.mapparallels;
    ell.a  = proj.geoid(1);
    ell.e  = proj.geoid(2);
    a = ell.a;
    e = ell.e;
    
    lat_ts = lat_ts * pi/180;
    
    if ( proj.nparallels > 1 | length(proj.mapparallels) > 1 )
        error ('Should not specify more than one standard parallel.');
    end
    if ( isempty(proj.nparallels) )
        error ('Should specify one standard parallel.');
    end

    % calculate "scale at the pole" (as given in the publication above):
    m_c = proj_polar_stereo_get_m (lat_ts, ell);
    t_c = proj_polar_stereo_get_t (lat_ts, ell);
    k_p = (1/2) * m_c * ...
        ( (1+e)^(1+e) * (1-e)^(1-e) )^0.5 / (a * t_c);  % (21-35)
        
    % calculate the scale factor at the origin:
    k_0 = k_p * a;  % this formula is not given in that publication

    proj2 = proj;
    %proj2.lat_ts = [];  proj2.k_0 = k_0;  % WRONG!
    proj2.mapparallels = [];  proj2.scalefactor = k_0;
    
    % It's interesting to note that k_0 = k_p * a,
    % where k_0 is the scale at the origin 
    % and k_p is the scale at the pole,
    % because the origin is at the pole!
    % That fact makes me expect that k_0 should be
    % the same quantity as k_p, i.e., k_p should not 
    % include the factor a. Furthermore, k approaches k_0
    % (not k_p) as phi approaches the pole (+90 degrees).
return;

%!test
%! % We shall get the same value for rho (and therefore x and y)
%! % calculating it using either the scale factor at origin or
%! % the latitude along which scale is true:
%! 
%! a = 6378388;  e = sqrt(0.00672267);
%! %a = 6371220;  e = 0;  % DEBUG
%! b = a * sqrt(1 - e^2);
%! f = (a - b) / a;
%! 
%! proj = defaultm('stereo');
%! proj.geoid = [a e];
%! %proj.origin = [90, -100];  proj.mapparallels = -71;
%! proj.origin = [90, -111];  proj.mapparallels = 60;
%! proj.nparallels = 1;
%! proj.scalefactor = [];
%! 
%! n = 10;
%! lat =  -90 + 180*rand(n, 1);
%! lon = -180 + 360*rand(n, 1);
%!   %[lat lon]  % DEBUG
%! 
%! [x, y, k] = proj_polar_stereo (proj, lat, lon);
%! proj2 = proj_polar_stereo_get_scale_factor (proj);
%! [x2, y2, k2] = proj_polar_stereo (proj2, lat, lon);
%!   %norm_all([x y] - [x2 y2])  % DEBUG
%! 
%! myassert (x, x2, sqrt(eps()));
%! myassert (y, y2, sqrt(eps()));
%! myassert (k, k2, sqrt(eps()));
%! myassert (max(abs(k2-k))~=0);  % all zero is suspecious

