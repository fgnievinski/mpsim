function ell = get_ellipsoid (name)
%GET_ELLIPSOID: Return geodetic ellipsoid information.

    if (nargin < 1) || isempty(name),  name = 'grs80';  end
    switch lower(name)
    case 'clk1866'
        ell.a = 6378206.40;
        ell.b = 6356583.80;
        ell.f = (ell.a - ell.b) / ell.a;
        ell.e = sqrt( (ell.a^2 - ell.b^2) / ell.a^2 );
    case 'iau_earth'
        ell.a = 6378.14e3;
        ell.b = 6356.75e3;
        ell.f = (ell.a - ell.b) / ell.a;
        ell.e = sqrt( (ell.a^2 - ell.b^2) / ell.a^2 );
    case 'grs80'
        ell.a = 6378137;
        ell.e_sq = 0.00669438002290;
        ell.e = sqrt(ell.e_sq);
        ell.b = ell.a * sqrt(1 - ell.e_sq);
        ell.f = (ell.a - ell.b) / ell.a;
    case 'int24'
        % RESOLU��O IBGE 1/2005.
        ell.a = 6378388;
        ell.f = 1/297;
        ell.b = ell.a * (1 - ell.f);
        ell.e = sqrt( (ell.a^2 - ell.b^2) / ell.a^2 );
    case 'int67'
        % RESOLU��O IBGE No 23, DE 21 DE FEVEREIRO DE 1989
        ell.a = 6378160;
        ell.b = 6356774.719;
        ell.f = (ell.a - ell.b) / ell.a;
        ell.e = sqrt( (ell.a^2 - ell.b^2) / ell.a^2 );
    case 'fake'
        % I've made this ellipsoid really different from 
        % Earth's shape, so as to have large discrepancies
        % in gedetic coordinates expressed in this ellipsoid,
        % compared to, say, GRS80 or WGS84.
        ell.a = 6378000;
        ell.b = 6300000;
        ell.f = (ell.a - ell.b) / ell.a;
        ell.e = sqrt( (ell.a^2 - ell.b^2) / ell.a^2 );
    case 'wgs84'
        %-% WGS-84 ellipsoid parameters.
        
        %   <http://earth-info.nga.mil/GandG/tr8350_2.html>
        %   <ftp://164.214.2.65/pub/gig/tr8350.2/wgs84fin.pdf>

        ell.a = 6378137.0;  % semi-major axis
        ell.f = 1.0 / 298.2572235630;  % flattening
        ell.b = ell.a * (1 - ell.f);  % semi-minor axis
        ell.e = sqrt ( (ell.a^2 - ell.b^2) / (ell.a^2));  % first eccentricity

        %-%
        % Paremeters needed to evaluate the geopotential.
        % I got them from the US National Geospatial-Inteligence Agency's
        % website, "NGA/NASA EGM96, N=M=360 Earth Gravity Model" 
        % (NGA > Products and Services >Geospatial Sciences Division 
        % > Physical Geodesy Home)
        % <http://earth-info.nga.mil/GandG/wgsegm/egm96.html>
            
        % Earth's Gravitational Constant w/ atmosphere:
        ell.GM = 0.3986004418e15;  % m^3/s^2
        
        % Earth's angular speed:
        ell.omega = 7292115.0e-11;   % rad/s
        
        % Dynamical form factor of the Earth:
        % The four defining paramenters of WGS-84 are
        % GM, omega, a, and 1/f. We need J2 instead of f:
        ell.J2 = get_J2 (ell.a, ell.b, ell.omega, ell.GM);

        % value used to compute N from the EGM96 harmonic coefficients:
        % (even though W_0 is not strictly related to the ellipsoid,
        %  I thought that's the best place to keep it)
        ell.W0 = 62636856.88;  % m^2 s^2
        % Accordingly to eq. (11.2-3) in Chapter 11, "The EGM96 Geoid 
        % Undulation With Respect to the WGS84 Ellipsoid", of the following 
        % publication: The Development of the Joint NASA GSFC and NIMA 
        % Geopotential Model EGM96, F. G. Lemoine, S. C. Kenyon, J. K. Factor, 
        % R.G. Trimmer, N. K. Pavlis, D. S. Chinn, C. M. Cox, S. M. Klosko, 
        % S. B. Luthcke, M. H. Torrence, Y. M. Wang, R. G. Williamson, 
        % E. C. Pavlis, R. H. Rapp and T. R. Olson, NASA Goddard Space Flight 
        % Center, Greenbelt, Maryland, 20771 USA, July 1998. Available at:
        % <http://cddis.gsfc.nasa.gov/926/egm96/doc/S11.HTML>
       
        %-%
        % Value taken from NIMA Technical Report TR8350.2, 
        % "Department of Defense World Geodetic System 1984, Its Definition 
        % and Relationships With Local Geodetic Systems", Third Edition, 
        % 4 July 1997, available at
        % <ftp://164.214.2.65/pub/gig/tr8350.2/wgs84fin.pdf>
        % Table 3.4 (Derived physical constants), printed page 3-7, PDF page 40.
        ell.U0 = 62636851.7146;  %  m^2/s^2
        ell.U0_tol =    0.00005;  % half the least significant digit in U0
    case {'wgs84_sph', 'sph', 'sphere'}
        ell = get_ellipsoid('wgs84');
        R = (ell.a + ell.b) / 2;
        ell.a = R;
        ell.b = R;
        ell.f = 0;
        ell.e = 0;
        ell.J2 = 0;
    case 'mean sphere'
        R = 6371e3;
        ell.a = R;
        ell.b = R;
        ell.f = 0;
        ell.e = 0;
    otherwise
        error('MATLAB:get_ellipsoid:unkEll', 'Unknown ellipsoid name "%s".', name);
    end
end

%!test
%! names = {'grs80', 'int24', 'int67', 'fake', 'wgs84', 'wgs84_sph', 'sph'};
%! for i=1:length(names)
%!     get_ellipsoid (names{i});
%! end

%!test
%! % get_ellipsoid ()
%! lasterror('reset')

%!error
%! get_ellipsoid('WRONG');

%!test
%! % get_ellipsoid ()
%! s = lasterror;
%! %s
%! myassert(strcmp(s.identifier, 'MATLAB:get_ellipsoid:unkEll'));

