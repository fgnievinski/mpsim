function [fresnel_zone, fresnel_zone_number] = delay2fresnel (...
delay, wavelength, detrendit)
    if (nargin < 3) || isempty(detrendit),  detrendit = true;  end
    if detrendit
        delay_min = min(delay(:));
        delay_excess = delay - delay_min;
    else
        delay_excess = delay;
    end
    % Each Fresnel zone corresponds to half period:
    fresnel_zone = 2 .* delay_excess ./ wavelength;
    if (nargout < 2),  return;  end
    fresnel_zone_number = ceil(fresnel_zone);
    %fresnel_zone_number = floor(fresnel_zone);  %WRONG!
end
