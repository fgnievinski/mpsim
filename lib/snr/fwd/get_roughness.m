function [phasor_rough, optimizeit] = get_roughness (...
height_std, wavelength, elev, elev2, optimizeit)
    if (nargin < 4),  elev2 = [];  end
    if (nargin < 5) || isempty(optimizeit),  optimizeit = true;  end
    if optimizeit && all(height_std(:) == 0),  height_std = [];  end
    if isempty(height_std)
        phasor_rough = 1;
        return;
    end
    if optimizeit && isequaln(elev2, elev),  elev2 = [];  end
    if isempty(elev2)
        temp = (sind(elev)).^2;
    else
        %temp = sind(elev) .* sind(elev2);
        temp = ( sind(elev) + sind(elev2) ).^2;
        % (sind(elev) + sind(elev2)).^2 is given by Ogilvy (p.88, eq.4.43).
        % also by Beckmann (eq.51, p.88, sec.5, and eq.10, p.82; 
        % eq.5 & 6, p.81 have typos.)
        temp = temp ./ 4;  % so that temp == (sind(elev)).^2 when elev2=elev;
    end
    sigma = height_std;
    k = 2*pi / wavelength;
    phasor_rough = exp(- (1/2) .* (k .* sigma).^2 .* temp);
    % the 1/2 factor sometimes appears as a 2 in the literature, 
    % when using the wavelength instead of wavenumber:
    %phasor_rough = exp(- 2*pi^2 / wavelength^2 .* sigma.^2 .* temp);
end

%!test
%! height_std = rand;
%! wavelength = rand;
%! elev = randint(0,90);
%! elev2 = elev;
%! [phasor_rough1, optimizeit1] = get_roughness (height_std, wavelength, elev, elev2, true);
%! [phasor_rough2, optimizeit2] = get_roughness (height_std, wavelength, elev, elev2, false);
%! assert(optimizeit1 == true)
%! assert(optimizeit2 == false)
%! %[phasor_rough1, phasor_rough2, phasor_rough2-phasor_rough1]  % DEBUG
%! myassert(phasor_rough2, phasor_rough1)

