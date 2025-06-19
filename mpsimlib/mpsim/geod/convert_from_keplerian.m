function [pos, vel] = convert_from_keplerian (element, GM, t, implem)
%CONVERT_FROM_KEPLERIAN: Convert from Keplerian elements, to position and velocity in celestial reference frame.

% Input angular quantities in radians, NOT degrees.
    if (nargin < 2) || isempty(GM)
        % GM = G * M
        % G = gravitational constant
        % M = mass of the Earth
        GM = 39860.5 * (1e3)^3;  % in m^3/s^2.
    end
    %GM  % DEBUG
    if (nargin < 3)
        t = [];
    end
    if (nargin < 4) || isempty(implem)
        implem = 'compact';
        %implem = 'expanded';
    end
    if ~any(strcmp(implem, {'compact','expanded'}))
        error('MATLB:convert_from_keplerian:unkImplem', ...
        'Unknown implementation = "%s".', char(implem));
    end

    % unpack elements:
    a     = element.a;      % semi-major axis
    e     = element.e;      % eccentricity
    i     = element.i;      % inclination
    omega = element.omega;  % argument of periapse
    Omega = element.Omega;  % right ascension of the ascending node
    
    % here we define the order of preference for the variable specifying 
    % the satellite position on the orbital plane:
    if isfield(element, 'f')
        % true anomaly:
        f = element.f;
    else
        if isfield(element, 'E')
            % eccentric anomaly:
            E = element.E;
        else
            if isfield(element, 'M')
                % mean anomaly:
                M = element.M;
            else
                if isfield(element, 'Dtp')
                    % period of time elapsed since 
                    % latest periapse passage until the current epoch:
                    Dtp = element.Dtp;
                else
                    if isfield(element, 'tau')
                        % "time" of periapse passage:
                        tau = element.tau;
                        %disp('hw!')  % DEBUG
                    else
                        error('MATLAB:convert_from_keplerian:badPos', ...
                       'At least one of f, E, M, Dtp, or tau must be specified.');
                    end

                    % epoch:
                    if isempty(t)
                        error('MATLAB:convert_from_keplerian:missEpoch', ...
                        ['When the sallite position on the orbital plane is',...
                         ' specified with the "time" of periapse passage ',...
                         'tau, the desired epoch t must be specified as well.']);
                    end

                    % orbit period:
                    T = get_orbit_period (a, GM);

                    % period of time elapsed since reference periapse passage, 
                    % as calculated directly from the epoch t:
                    Dtp2 = mod(t, T);

                    % period of time elapsed since reference periapse passage, 
                    % as calculated from the mean anomaly M in 
                    % convert_to_keplerian.m:
                    Dtp = Dtp2 - tau;
                end
                % mean anomaly:
                n = sqrt(GM./a.^3);
                M = n .* Dtp;
            end
            % eccentric anomaly:
            E = convert_anomaly_mean_to_eccentric (M, e);
        end
        % true anomaly:
        temp = sqrt((1+e)./(1-e)) .* tan(E./2);
        f = atan(temp) * 2;
    end
    
    % semilatus rectum:
    p = a .* (1 - e.^2);  

    % specific angular momentum (magnitude only):
    h = sqrt(GM * p);
    %h = sqrt(GM) * sqrt(p);

    % radius:
    r = p ./ (1 + e .* cos(f));

    % angle on the orbital plane:
    theta = omega + f;

    if strcmp(implem, 'compact')
        % principal directions on the orbital plane:
        [u_r(:,1), u_r(:,2), u_r(:,3)] = sph2cart(theta,      0, 1);
        [u_t(:,1), u_t(:,2), u_t(:,3)] = sph2cart(theta+pi/2, 0, 1);
        myassert(abs(dot_all(u_t, u_r) < 10*eps))  % orthonormal.

        % principal directions in celestial reference frame:
        R1 = get_rot (1, -i*180/pi);
        R3 = get_rot (3, -Omega*180/pi);
          R3 = frontal(R3);
          R1 = frontal(R1);
          u_r = frontal(u_r, 'pt');
          u_t = frontal(u_t, 'pt');
        R = R3 * R1;  clear R1 R3
        u_r = (R * u_r')';
        u_t = (R * u_t')';
        clear R 
          u_r = defrontal(u_r, 'pt');
          u_t = defrontal(u_t, 'pt');
        
        % position in celestial reference frame:
        pos = u_r .* repmat(r, 1, 3);
        
        % velocity in celestial reference frame:
        vel = u_r .* repmat((h .* e .* sin(f) ./ p), 1, 3) ...
            + u_t .* repmat(h./r, 1, 3);
        v = sqrt(GM * (2./r - 1./a));            
        %max(abs(norm_all(vel) - v))  % DEBUG
        myassert(abs(norm_all(vel) - v) < sqrt(eps))
    else
% position in celestial reference frame:
x = r .* (cos(Omega) .* cos(theta) - sin(Omega) .* sin(theta) .* cos(i)); 
y = r .* (sin(Omega) .* cos(theta) + cos(Omega) .* sin(theta) .* cos(i)); 
z = r .* (                                         sin(theta) .* sin(i)); 
pos = [x, y, z];

% velocity in celestial reference frame:
x = pos(:,1);
y = pos(:,2);
z = pos(:,3);
p = a .* (1 - e.^2);  % semilatus rectum.    
vel_x = x.*h.*e./(r.*p).*sin(f) ...
    - (h./r).*( cos(Omega).*sin(theta) + sin(Omega).*cos(theta).*cos(i) );
vel_y = y.*h.*e./(r.*p).*sin(f) ...
    - (h./r).*( sin(Omega).*sin(theta) - cos(Omega).*cos(theta).*cos(i) );
vel_z = z.*h.*e./(r.*p).*sin(f) ...
    + (h./r).*(                                      cos(theta).*sin(i) );
vel = [vel_x, vel_y, vel_z];
    end
end

function E = convert_anomaly_mean_to_eccentric (M, e)
    tol = 10*eps;  % 1*eps is too stringent.
    % M = E - e .* sin(E);
    func = @(E, e) E - e .* sin(E);
    rate = @(E, e) 1 ./ (1 - e .* cos(E));  % dE/dM = 1 / (dM/dE).
    E_approx = M;  % initial guess to start the iteration (p.27).
    while (true)
        M_approx = func(E_approx, e);
        M_discr = M_approx - M;
        %max(abs(M_discr))  % DEBUG
        %sum(abs(M_discr) >= tol)  % DEBUG
        E_approx = E_approx - M_discr .* rate(E_approx, e);
        if all(abs(M_discr) < tol)
            % converged for all elements.
            break;
        end
    end
    E = E_approx;
end
%function E = convert_anomaly_mean_to_eccentric (M, e)
%    % M = E - e .* sin(E);
%    func = @(E, e) E - e .* sin(E);
%    rate = @(E, e) 1 ./ (1 - e .* cos(E));  % dE/dM = 1 / (dM/dE).
%    E_approx = M;  % initial guess to start the iteration (p.27).
%    idx = true(size(M));  % index for non-converged elements.
%    M_approx = NaN(size(M));
%    while (true)
%        sum(idx)  % DEBUG
%        M_approx(idx) = func(E_approx(idx), e(idx));
%        M_discr(idx) = M_approx(idx) - M(idx);
%        M_discr = reshape(M_discr, size(M));
%        idx = (abs(M_discr) > eps);
%        if ~any(idx)
%            % converged for all elements.
%            break;
%        end
%        size(M_discr(idx)), size(rate(E_approx(idx), e(idx)))  % DEBUG
%        E_approx(idx) = E_approx(idx) ...
%            - M_discr(idx) .* rate(E_approx(idx), e(idx));
%    end
%    E = E_approx;
%end

