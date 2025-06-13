% GEOD
%
% Files
%   convert_any                        - CONVERT_ANY: Convert from any type of coordinates to any other type of coordinates.
%   convert_direction_from_cartesian   - CONVERT_DIRECTION_FROM_CARTESIAN: Convert from local direction cosines to elevation angle and azimuth.
%   convert_direction_to_cartesian     - CONVERT_DIRECTION_TO_CARTESIAN: Convert from elevation angle and azimuth to local direction cosines.
%   convert_from_any                   - CONVERT_FROM_ANY: Convert any type of coordinates, to global Cartesian coordinates.
%   convert_from_cartesian             - CONVERT_FROM_CARTESIAN: Convert from global Cartesian coordinates, to geodetic curvilinear coordinates.
%   convert_from_ellipsoidal_harmonic  - CONVERT_FROM_ELLIPSOIDAL_HARMONIC: Convert from ellipsoidal-harmonic coordinates, to global Cartesian coordinates.
%   convert_from_geodetic              - CONVERT_FROM_GEODETIC:  Convert from geodetic (ellipsoidal curvilinear) coordinates, to global Cartesian coordinates.
%   convert_from_geodm                 - CONVERT_FROM_GEODM: Convert from ellipsoidal arc-lengths (at non-zero height), to geodetic coordinates.
%   convert_from_geopot_height         - CONVERT_FROM_GEOPOT_HEIGHT: Convert from geopotential height -- and geodetic latitude and longitude --, to ellipsoidal height.
%   convert_from_geopot_height_abs     - CONVERT_FROM_GEOPOT_HEIGHT_ABS: Convert from geopotential height (absolute) -- and geodetic latitude and longitude --, to ellipsoidal height.
%   convert_from_geopot_height_rel     - CONVERT_FROM_GEOPOT_HEIGHT_REL: Convert from geopotential height (relative to the geoid) -- and geodetic latitude and longitude --, to ellipsoidal height.
%   convert_from_keplerian             - CONVERT_FROM_KEPLERIAN: Convert from Keplerian elements, to position and velocity in celestial reference frame.
%   convert_from_local_cart            - CONVERT_FROM_LOCAL_CART: Convert from local Cartesian coordinates, to global Cartesian coordinates (orthogonally), and then (optionally) to geodetic curvilinear coordinates.
%   convert_from_local_cart_viageod    - CONVERT_FROM_LOCAL_CART_VIAGEOD: Convert from local Cartesian coordinates, to geodetic curvilinear coordinates, and then (optionally, non-orthogonally) to global Cartesian coordinates.
%   convert_from_local_sph             - CONVERT_FROM_LOCAL_SPH: Convert from local spherical coordinates, to global Cartesian coordinates; local Cartesian coordinates are available as a by-product.
%   convert_from_spherical             - CONVERT_FROM_SPHERICAL: Convert from global spherical coordinates, to global Cartesian coordinates.
%   convert_to_any                     - CONVERT_TO_ANY:  Convert from global Cartesian coordinates to any other type of coordinates.
%   convert_to_cartesian               - CONVERT_TO_CARTESIAN: Convert to global Cartesian coordinates, given geodetic curvilinear coordinates.
%   convert_to_ellipsoidal_harmonic    - CONVERT_TO_ELLIPSOIDAL_HARMONIC: Convert to ellipsoidal-harmonic coordinates, given global Cartesian coordinates.
%   convert_to_geodetic                - CONVERT_TO_GEODETIC:  Convert to geodetic (ellipsoidal curvilinear) coordinates, given global Cartesian coordinates.
%   convert_to_geodm                   - CONVERT_TO_GEODM: Convert to ellipsoidal arc-lengths (at non-zero height), given geodetic coordinates.
%   convert_to_geopot_height           - CONVERT_TO_GEOPOT_HEIGHT:  Convert to geopotential height, given geodetic coordinates.
%   convert_to_geopot_height_abs       - CONVERT_TO_GEOPOT_HEIGHT_ABS: Convert to geopotential height (absolute), given geodetic coordinates.
%   convert_to_geopot_height_rel       - CONVERT_TO_GEOPOT_HEIGHT_REL:  Convert to geopotential height (relative to the geoid), given geodetic coordinates.
%   convert_to_keplerian               - CONVERT_TO_KEPLERIAN: Convert to Keplerian elements, given position and velocity in celestial reference frame.
%   convert_to_latm                    - CONVERT_TO_LATM: Return meridian arc-length (at non-zero height), given geodetic latitude and height.
%   convert_to_local_cart              - CONVERT_TO_LOCAL_CART: Convert to local Cartesian coordinates, given global Cartesian coordinates.
%   convert_to_local_cart_viageod      - CONVERT_TO_LOCAL_CART_VIAGEOD: Convert to local Cartesian coordinates, given geodetic curvilinear coordinates.
%   convert_to_local_sph               - CONVERT_TO_LOCAL_SPH: Convert to local spherical coordinates, given global Cartesian coordinates; local Cartesian coordinates are available as a by-product.
%   convert_to_spherical               - CONVERT_TO_SPHERICAL: Convert to global spherical coordinates, given global Cartesian coordinates.
%   get_centrifugal_potential          - GET_CENTRIFUGAL_POTENTIAL: Return centrifugal potential, given a position in global spherical -- NOT GEODETIC -- coordinates.
%   get_ellipsoid                      - GET_ELLIPSOID: Return geodetic ellipsoid information.
%   get_ellipsoid_normal               - GET_ELLIPSOID_NORMAL: Return ellipsoidal normal direction (in global Cartesian coordinates), at given geodetic position.
%   get_geoidal_undulation             - GET_GEOIDAL_UNDULATION: Return the geoidal undulation at a given geodetic position.
%   get_geopot                         - GET_GEOPOT: Return geopotential (Earth's gravity potential), given a position in global spherical -- NOT GEODETIC -- coordinates.
%   get_geopot_actual                  - GET_GEOPOT_ACTUAL: Return the actual geopotential, given a position in global spherical -- NOT GEODETIC -- coordinates.
%   get_geopot_normal                  - GET_GEOPOT_NORMAL: Return the normal geopotential, given a position in global spherical -- NOT GEODETIC -- coordinates.
%   get_geopot_normal_exact            - GET_GEOPOT_NORMAL_EXACT: Return the normal geopotential (exact formula), given a position in global spherical -- NOT GEODETIC -- coordinates.
%   get_geopot_normal_series           - GET_GEOPOT_NORMAL_SERIES: Return the normal geopotential (spherical series expansion), given a position in global spherical -- NOT GEODETIC -- coordinates.
%   get_geopot_normal_trunc            - GET_GEOPOT_NORMAL_TRUNC: Return the normal geopotential (single-term truncated series), given a position in global spherical -- NOT GEODETIC -- coordinates.
%   get_geopot_rel                     - GET_GEOPOT_REL: Return geopotential, relative to a reference surface, given a position in global spherical -- NOT GEODETIC -- coordinates.
%   get_geopot_sph                     - GET_GEOPOT_SPH: Return geopotential of spherical Earth, given a position in global spherical -- NOT GEODETIC -- coordinates.
%   get_jacobian_any2cart              - GET_JACOBIAN_ANY2CART: Return the Jacobian matrix of global Cartesian coordinates w.r.t. any type of coordinate.
%   get_jacobian_any2geod              - GET_JACOBIAN_ANY2GEOD: Return the Jacobian matrix of geodetic coordinates w.r.t. any type of coordinate.
%   get_jacobian_cart2any              - GET_JACOBIAN_CART2ANY: Return the Jacobian matrix of any coordinate type w.r.t. global Cartesian coordinates.
%   get_jacobian_cart2geod             - GET_JACOBIAN_CART2GEOD: Return the Jacobian matrix of geodetic coordinates w.r.t. global Cartesian coordinates.
%   get_jacobian_cart2geodm            - GET_JACOBIAN_GEOD2GEODM: Return the Jacobian matrix of ellipsoidal arc-lengths w.r.t. global Cartesian coordinates.
%   get_jacobian_cart2local            - GET_JACOBIAN_CART2LOCAL: Return the Jacobian matrix of local Cartesian coordinates w.r.t. global Cartesian coordinates (directly).
%   get_jacobian_cart2local_viageod    - GET_JACOBIAN_CART2LOCAL_VIAGEOD: Return the Jacobian matrix of local Cartesian coordinates w.r.t. global Cartesian coordinates (via geodetic coordinates).
%   get_jacobian_geod2cart             - GET_JACOBIAN_GEOD2CART: Return the Jacobian matrix of global Cartesian coordinates w.r.t. geodetic coordinates.
%   get_jacobian_geod2geodm            - GET_JACOBIAN_GEOD2GEODM: Return the Jacobian matrix of ellipsoidal arc-lengths w.r.t. geodetic coordinates.
%   get_jacobian_geod2local            - GET_JACOBIAN_GEOD2LOCAL: Return the Jacobian matrix of local Cartesian coordinates w.r.t. geodetic coordinates (via global Cartesian coordinates).
%   get_jacobian_geod2local_viageod    - GET_JACOBIAN_GEOD2LOCAL_VIAGEOD: Return the Jacobian matrix of local Cartesian coordinates w.r.t. geodetic coordinates (directly).
%   get_jacobian_geodm2cart            - GET_JACOBIAN_GEODM2CART: Return the Jacobian matrix of global Cartesian coordinates w.r.t. ellipsoidal arc-lengths.
%   get_jacobian_geodm2geod            - GET_JACOBIAN_GEODM2GEOD: Return the Jacobian matrix of geodetic coordinates w.r.t. ellipsoidal arc-lengths.
%   get_jacobian_local2any             - GET_JACOBIAN_LOCAL2ANY: Return the Jacobian matrix of any coordinate type w.r.t. local Cartesian coordinates.
%   get_jacobian_local2cart            - GET_JACOBIAN_LOCAL2CART: Return the Jacobian matrix of global Cartesian coordinates w.r.t. local Cartesian coordinates (directly).
%   get_jacobian_local2cart_viageod    - GET_JACOBIAN_LOCAL2CART_VIAGEOD: Return the Jacobian matrix of global Cartesian coordinates w.r.t. local Cartesian coordinates (via geodetic coordinates).
%   get_jacobian_local2geod            - GET_JACOBIAN_LOCAL2GEOD: Return the Jacobian matrix of geodetic coordinates w.r.t. local Cartesian coordinates (via global Cartesian coordinates).
%   get_jacobian_local2geod_viageod    - GET_JACOBIAN_LOCAL2GEOD_VIAGEOD: Return the Jacobian matrix of geodetic coordinates w.r.t. local Cartesian coordinates (directly).
%   get_loxodrome_sph                  - GET_LOXODROME_SPH: Return the loxodrome (its azimuth and arc-length) between two points on a sphere.
%   get_meridian_arclen                - GET_MERIDIAN_ARCLEN: Return the meridian arc length (at zero height), from the equator up to a given latitude.
%   get_radius_eulerian                - GET_RADIUS_EULERIAN: Return the Eulerian (i.e., azimuth-dependent) ellipsoidal radius of curvature, from a given point to another point (both given in geodetic coordinates -- NOT JUST LATITUDE).
%   get_radius_gaussian                - GET_RADIUS_GAUSSIAN: Return the Gaussian (i.e., intrinsic) ellipsoidal radius of curvature, at a given geodetic latitude.
%   get_radius_mean                    - GET_RADIUS_MEAN: Return the mean ellipsoidal radius of curvature, at a given geodetic latitude.
%   get_radius_meridional              - GET_RADIUS_MERIDIONAL: Return the meridional (i.e., along the meridian section) ellipsoidal radius of curvature, at a given geodetic latitude.
%   get_radius_normal                  - GET_RADIUS_NORMAL: Return the normal (i.e., along the prime vertical section) ellipsoidal radius of curvature, at a given geodetic latitude.
%   get_sphere_normal                  - GET_SPHERE_NORMAL: Return the center (in global Cartesian coordinates) of a sphere normal to the ellipsod, at a given point (in geodetic coordinates) and having a given radius.
%   get_sphere_osculating              - GET_SPHERE_OSCULATING: Return the center (in global Cartesian coordinates) of an osculating sphere, i.e., normal to the ellipsod at a given point (in geodetic coordinates) and having radius equal to the Gaussian radius.
%   rand_pos_geod                      - RAND_POS_GEOD: Return random geodetic position; useful for testing.
%   setup_geoid                        - SETUP_GEOID: Setup geoid map.
%   setup_geopot                       - SETUP_GEOPOT: Setup geopotential coefficients.
