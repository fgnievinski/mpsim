% fresnel.m - Fresnel reflection coefficients for isotropic or birefringent media
%
% Usage: [rte,rtm] = fresnel(na,nb,theta)
%
% na,nb = 3-d vectors of refractive indices of left and right media, e.g., na=[na1,na2,na3]
% theta = array of incident angles from medium a (in degrees) at which to evaluate rho's
%
% rte,rtm = reflection coefficients for TE and TM polarizations
%
% notes: na,nb can be entered as 1-d, 2-d, or 3-d (row or column) vectors according to the cases:
%
%        isotropic  na = [na]                in all cases, na,nb are       na = [na;na;na]
%        uniaxial   na = [nao,nae]      ==>  turned into 3-d column   ==>  na = [nao;nao;nae]
%        biaxial    na = [na1,na2,na3]       vectors internally            na = [na1;na2;na3]
%
%        The function assumes that the interface is the x-y plane and that the plane of
%        incidence is the x-z plane, with the x,y,z axes being the diagonal optical axes
%        where x,y are ordinary axes and z, extraordinary. 
%
%        TE or s-polarization has E = [0,Ey,0], and ordinary indices na(2) or nb(2) on either side.
%
%        TM or p-polarization has E = [Ex,0,Ez], and theta-dependent refractive index, e.g.,
%                                               1/Na^2 = cos(th)^2/na(1)^2 + sin(th)^2/na(3)^2
% 
% examples: theta = 0:1:90;
%           [rte,rtm] = fresnel(1, 1.5, theta);             
%           [rte,rtm] = fresnel(1, [1.8,1.5], theta);       
%           [rte,rtm] = fresnel([1.8,1.5], 1.5, theta);     
%           [rte,rtm] = fresnel([1.8,1.5], [1.5,1.9], theta); 
%           [rte,rtm] = fresnel([1.5,1.8,1.5], [1.5,1.9], theta); 

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function [rte,rtm] = fresnel(na,nb,theta,convention)
if nargin==0, help fresnel; return; end
if (nargin < 4),  convention = 'orfanidis';  end

na = na(:); nb = nb(:);                                 % make them column vectors

if length(na)==1, na=[na; na; na]; end                  % isotropic case
if length(na)==2, na=[na(1); na(1); na(2)]; end         % uniaxial case
if length(nb)==1, nb=[nb; nb; nb]; end
if length(nb)==2, nb=[nb(1); nb(1); nb(2)]; end

theta = pi*theta/180;

Na = 1./sqrt(cos(theta).^2/na(1)^2 + sin(theta).^2/na(3)^2);       

xe = (na(2)*sin(theta)).^2;                                     % used in TE case        
xm = (Na.*sin(theta)).^2;                                       % used in TM case                    

rte = (na(2)*cos(theta) - sqrt(nb(2)^2 - xe)) ./ ...
      (na(2)*cos(theta) + sqrt(nb(2)^2 - xe));

if na(3)==nb(3),                                               
    rtm = (na(1) - nb(1)) / (na(1) + nb(1)) * ones(1,length(theta));
else
    rtm = (na(1)*na(3) * sqrt(nb(3)^2 - xm) - nb(1)*nb(3) * sqrt(na(3)^2 - xm)) ./ ...
          (na(1)*na(3) * sqrt(nb(3)^2 - xm) + nb(1)*nb(3) * sqrt(na(3)^2 - xm));
end

if ~strcmp(convention, 'orfanidis'),  rtm = -rtm;  end
% "Some references de?ne ?_TM with the opposite sign. Our convention was chosen because it has the expected limit at normal incidence."
% p.248, chap.5 in Sophocles J. Orfanidis, "Electromagnetic Waves and Antennas".
% <http://www.ece.rutgers.edu/~orfanidi/ewa/ch07.pdf>

