function [pos_reflection, dir_reflected, varargout] = get_reflection_point (...
height, elev, azim, slope, aspect)
    if (nargin < 1) || isempty(height),  height = 1.5;  end
    if (nargin < 2) || isempty(elev),  elev = 15;  end
    if (nargin < 3) || isempty(azim),  azim = 0;  end
    if (nargin < 4),  slope = [];  end
    if (nargin < 5),  aspect = [];  end
    if isscalar(azim),  azim = repmat(azim, size(elev));  end
    
    ref = snr_setup_origin (height);
    if isempty(slope) && isempty(aspect)
    %if isempty(slope) || isempty(aspect)  % WRONG!
        sfc = snr_setup_sfc_geometry_horiz (ref.pos_ant);
    else
        sfc = snr_setup_sfc_geometry_tilted (ref.pos_ant, [], struct('slope',slope, 'aspect',aspect));
    end
    sat = snr_setup_sat(struct('elev',elev, 'azim',azim));
    setup = struct('ref',ref, 'sfc',sfc, 'sat',sat);
    
    dir_incident.elev = elev;
    dir_incident.azim = azim;
    % call snr_fwd_geometry_reflection_horiz or snr_fwd_geometry_reflection_tilted, etc.:
    %[pos_reflected, dir_reflection, varargout{1:nargout}] = sfc.snr_fwd_geometry_reflection (...  % WRONG!
    [dir_reflected, pos_reflection, varargout{1:nargout}] = sfc.snr_fwd_geometry_reflection (...
        dir_incident, [], setup);
    pos_reflection = pos_reflection.cart;
end

%!test
%! % vectorial height:
%! height = [3; 2; 1];
%! elev = [1 45 90]';
%! pos_refl = get_specular_point (height, elev)

%!test
%! height = 2;
%! elev = linspace(0, 90, 10)';
%! pos_refl = get_specular_point (height, elev);
%! R1 = sqrt(sum(pos_refl(:,1:2).^2, 2));
%! R2 = get_fresnel_zone_dim (height, elev, [], 0);
%! %[R1, R2, R2-R1]  % DEBUG
%! idx = isnan(R1) | isnan(R2);
%! R1(isnan(R2)) = NaN;
%! R2(isnan(R1)) = NaN;
%! myassert(R1, R2, -sqrt(eps()))

%!test
%! % non-empty zero slope as well as negligible slope:
%! elev = linspace(1,90)';
%! azim = 0;
%! [pos_refl1, dir_refl1, dist1] = get_reflection_point (2, elev, azim);
%! [pos_refl2, dir_refl2, dist2] = get_reflection_point (2, elev, azim, 0, 0);
%! [pos_refl3, dir_refl3, dist3] = get_reflection_point (2, elev, azim, eps(), eps());
%! figure
%!   hold on
%!   plot(pos_refl1(:,2), pos_refl1(:,1), '.-b')
%!   plot(pos_refl2(:,2), pos_refl2(:,1), '.-r')
%!   plot(pos_refl3(:,2), pos_refl3(:,1), '.-g')
%!   xlabel('X (m)');  ylabel('Y (m)')
%! figure
%!   hold on
%!   plot(norm_all(pos_refl1(:,1:2)), pos_refl1(:,3), '.-b')
%!   plot(norm_all(pos_refl2(:,1:2)), pos_refl2(:,3), '.-r')
%!   plot(norm_all(pos_refl3(:,1:2)), pos_refl3(:,3), '.-g')
%!   xlabel('H (m)');  ylabel('V (m)')
%! figure
%!   hold on
%!   plot(dir_refl1.azim, dir_refl1.elev, '.-b')
%!   plot(dir_refl2.azim, dir_refl2.elev, '.-r')
%!   plot(dir_refl3.azim, dir_refl3.elev, '.-g')
%!   xlabel('Azimuth (degrees)');  ylabel('Elevation angle (degrees)')
%! figure
%!   hold on
%!   plot(dir_refl1.elev, dist1, '.-b')
%!   plot(dir_refl2.elev, dist2, '.-r')
%!   plot(dir_refl3.elev, dist3, '.-g')
%!   xlabel('Elevation angle (degrees)');  ylabel('Excess distance (m)')
