function perm = permittivity_realimag2complex (perm_real, perm_imag, convention)
    if (nargin < 3),  convention = [];  end
    convention = get_phase_convention (convention);
    switch convention
    case 'physics',  % change nothing
    case 'engineering',  perm_imag = -perm_imag;
    end
    perm = complex(perm_real, perm_imag);
    % the sign convention needs to be consistent with that of 
    % get_phase_inv and permittivity_complex2realimag.
    % (see test below)
end

%! % Space-time dependence:
%! %   exp(-1i*freq*time + 1i*wavenum*dist)  % physics
%! %   exp(+1i*freq*time - 1i*wavenum*dist)  % engineering
%! % Complex permittivity:
%! %   eps = re_eps + 1i*im_eps  % physics
%! %   eps = re_eps - 1i*im_eps  % engineering
%! % For both physics and engineering, in lossy media:
%! %   im_eps > 0 for lossy media.
%! % Medium wavenumber (k):
%! %   wavenum = wavenum0 * sqrt(perm)
%! % Free-space real-valued wavenumber (k_0):
%! %   wavenum0 = 2*pi/wavelen0
%! % with free-space wavelength (wavelen0).
%! %
%! % So the space dependence can be rewritten as (using any of s=+1 or s=-1):
%! %   exp(s*1i*wavenum*dist) = exp(s*1i*2*pi/wavelen0*sqrt(perm)*dist)
%! % or, defining the equivalent free-space phase0 = 2*pi*dist/wavelen0:
%! %   exp(s*1i*wavenum*dist) = exp(s*1i*phase0*sqrt(perm))
%! % So the conversion from a phase to a phasor requires not only the sign 
%! % convention itself (s) but also the permittivity (perm)!
%! % 
%! % Expanding sqrt(perm) = n + s*1i*K, where K is the extinction coefficient:
%! %   exp(s*1i*wavenum*dist) = exp(s*1i*phase0*(n+s*1i*K))
%! % Isolating the magnitude factor, we have:
%! %   exp(s*1i*wavenum*dist) = exp(s*1i*phase0*n)*exp(s^2*1i^2*phase0*K)
%! %   exp(s*1i*wavenum*dist) = exp(s*1i*phase0*n)*exp(-phase0*K)
%! % where we always have s^2=+1 and 1i^2=-1. For the wave to extinguish as 
%! % it travels into the medium, the real-valued phase0 has to increase with
%! % traveled distance (dist), so that there's an exponential decay: 
%! %   exp(-phase0*K) < 1 for phase0 > 0.
%! % Notice the sign factor does not enter the magnitude factor, only the 
%! % unit phase factor.
%! % 
%! %   exp(s*1i*wavenum*dist) = exp(s*1i*phase0*sqrt(perm))
%! %   exp(s*1i*wavenum*dist) = exp(s*1i*phase0*n)*exp(-phase0*K)

    
%!shared
%! conventions = {'engineering','physics'};

%!test
%! % complex-valued phasor is not the same acros conventions, but real-valued phasor components are:
%! perm_real = rand();
%! perm_imag = rand();
%! for i=1:2
%!   perm = permittivity_realimag2complex (perm_real, perm_imag, conventions{i});
%!   [perm_real2, perm_imag2] = permittivity_complex2realimag (perm, conventions{i});
%!   perm2 = permittivity_realimag2complex (perm_real2, perm_imag2, conventions{i});
%!   disp(conventions{i})
%!   [perm_real2, perm_real, perm_real2-perm_real]
%!   [perm_imag2, perm_imag, perm_imag2-perm_imag]
%!   [perm2, perm, perm2-perm]
%!   myassert(perm_real2, perm_real, -10*eps)
%!   myassert(perm_imag2, perm_imag, -10*eps)
%!   myassert(perm2, perm, -10*eps)
%! 
%!   perma = permittivity_realimag2complex (perm_real, perm_imag, conventions{1});
%!   permb = permittivity_realimag2complex (perm_real, perm_imag, conventions{2});
%!   %[perma; permb; perma-permb]
%!   assert(perma~=permb)
%! end

%!test
%! % phase-advance rotates the phasor in the same direction for any convention:
%! for i=1:2
%!   temp1 = permittivity_realimag2complex (0, 1, conventions{i});
%!   temp2 = phasor_init(1, 90, conventions{i});
%!   assert(imag(temp1) == imag(temp2))
%! end

%!test
%! % permittivity_realimag2complex()
%! % consistency check:
%! n = 10;
%! ph = rand(n,1);
%! for i=1:2
%!   disp(conventions{i})  % DEBUG
%!   temp = get_phase_inv(ph, conventions{i});
%!   ph2 = get_phase(temp, conventions{i});
%!   [ph, ph2, ph2-ph]  % DEBUG
%!   myassert(ph2, ph, -10*eps)
%! end

%!test
%! % permittivity_realimag2complex()
%! % power should be lost in forward propagation in a lossy medium:
%! material = 'seawater';
%! material = 'freshwater';
%! %material = 'dry snow fixed';
%! lambda0 = 24e-2;  % in m
%! k0 = 2*pi/lambda0;
%! dist = linspace(0,0.1, 10)';
%! for i=1:2
%!   disp(conventions{i})  % DEBUG
%!   eps = get_permittivity(material, [], [], [], conventions{i});
%!   k = k0 * sqrt(eps);
%!   phase = k*dist*180/pi;
%!   fwdprop = get_phase_inv(phase, conventions{i});
%!   temp = [dist, abs(fwdprop).^2];
%!   cprintf(temp, '-Lc',{'Distance (m)', 'Power change (W/W)'})
%!   myassert(all(fwdprop <= 1))
%! end
%! %error('blah')  % DEBUG

% From Orfanidis, "Electromagnetic Waves and Antennas", <http://www.ece.rutgers.edu/~orfanidi/ewa/>
% 
% Eq. (1.11.9):
% 
%   \epsilon(\omega) = \epsilon'(\omega) - j \epsilon"(\omega)
%  
% Eq. (1.12.2):
% 
%   \epsilon(\omega) = ... = \epsilon_0 + \sigma(\omega) / (j \omega)
%   \epsilon(\omega) = ... = \epsilon_0 - j \sigma(\omega) / \omega
% 
% Eq. (1.14.2):
% 
%   \epsilon(\omega) = ... = \epsilon_d(\omega) + \sigma(\omega) / (j \omega)
% 
% Eq. (2.6.1):
% 
%   j \omega \epsilon_c = \sigma +j \omega \epsilon_d
%   =>
%   \epsilon_c = \epsilon_d - j \sigma / \omega
%   \epsilon_c = \epsilon_d + \sigma / (j \omega)
% 
% Eq. (2.6.2):
% 
%   \epsilon_c = \epsilon' - j \epsilon" 
%              = \epsilon'_d - j (\epsilon"_d + \sigma / \omega)
% 
