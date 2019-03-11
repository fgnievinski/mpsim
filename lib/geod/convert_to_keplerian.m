function element = convert_to_keplerian (pos, vel, GM, t)
%CONVERT_TO_KEPLERIAN: Convert to Keplerian elements, given position and velocity in celestial reference frame.

% Input:
%   pos: position vector, in m
%   vel: velocity vector, in m/s
% Both input spatial vectors are to be given in the 
% celestial reference frame (quasi-inertial), 
% NOT terrestrial (Earth Centered, Earth Fixed).
    if (nargin < 3) || isempty(GM)
        % GM = G * M
        % G = gravitational constant
        % M = mass of the Earth
        GM = 398600.5 * (1e3)^3;  % in m^3/s^2.
    end
    %GM  % DEBUG
    if (nargin < 4)
        t = [];
    end
    %GM  % DEBUG

    % specific angular momentum:
    h_vec = cross_all (pos, vel);  % vector 
    h = norm_all (h_vec);  % magnitude
    h_x = h_vec(:,1);  % X component
    h_y = h_vec(:,2);  % Y component
    h_z = h_vec(:,3);  % Z component

    % radius and speed:
    r = norm_all (pos);
    v = norm_all (vel);

    % specific total energy:
    xi = v.^2./2 - GM./r;

    % semi-major axis:
    a = - GM ./ (2 * xi);

    % eccentricity:
    e = sqrt(1 - h.^2 ./ (a * GM));
    %e = sqrt(1 - h./sqrt(a*GM) .* h./sqrt(a.*GM));

    % inclination:
    i = acos(h_z ./ h);

    % right ascension of the ascending node:
    Omega = atan2(h_x, -h_y);
    
    % argument of latitude:
    pos_x = pos(:,1);
    pos_y = pos(:,2);
    pos_z = pos(:,3);
    temp = pos_x .* cos(Omega) + pos_y .* sin(Omega);
    omega_nu = atan2(pos_z./sin(i), temp);

    % true anomaly:
    p = a .* (1 - e.^2);  % semilatus rectum.
    f = atan2((p./h) .* dot_all(pos, vel), p - r);
    %f = atan2(sqrt(p./GM) .* dot_all(vel, pos), p - r);
    %f = acos((p - r) ./ (e .* r));
    %idx = (dot_all(pos, vel) > 0);
    %f(idx) = - f(idx);

    % argument of periapse:
    omega = omega_nu - f;
    idx = (omega < 0);  omega(idx) = 2*pi + omega(idx);

    % eccentric anomaly:
    temp = sqrt((1-e)./(1+e)) .* tan(f./2);
    E = atan(temp) * 2;

    % mean anomaly:
    M = E - e .* sin(E);
    
    % period of time elapsed since 
    % latest periapse passage until the current epoch:
    n = sqrt(GM./a.^3);
    Dtp = M ./ n;

    % 
    if isempty(t)
        tau = [];
    else
        % orbit period:
        T = get_orbit_period(a, GM);

        % period of time elapsed since latest periapse passage, 
        % as calculated from the epoch t instead of from the 
        % mean anomaly M:
        Dtp2 = mod(t, T);

        % "time" of periapse passage (not an epoch nor a period):
        tau = Dtp2 - Dtp;

        % fix quadrants:
        DM = tau .* n;  % make it an angle.
        DM = atan2(sin(DM), cos(DM));
        tau = DM ./ n;  % make it time again.
    end

    
    % pack results:
    %a, e, i*180/pi, omega*180/pi, Omega*180/pi, E*180/pi, M*180/pi, f*180/pi, p, r, v  % DEBUG
    element.a     = a;
    element.e     = e;
    element.i     = i;
    element.omega = omega;
    element.Omega = Omega;
    element.f     = f;
    element.E     = E;
    element.M     = M;
    element.Dtp   = Dtp;
    element.tau   = tau;
    element.n     = n;
end

