%==========================================================================
%
% Title: refl_mlm_M
% Stands for "REFLection from Multi-Layered Medium" 
% Authors: Valery Zavorotny
% Date written: 29 May 2008 (Originates from the Fortran subroutine
% sigmaml.for, 2004, which in its turn is based on 2-layer code sigma0.for (2002)
% Date last modified: Aug 15 2008 (introduced a dependence of the local
% incidence angle on the layer index)
% Copyright 2008 NOAA/ESRL/PSD3, Boulder
% Mofified on Dec. 2, 2008

% Purpose: this script computes Fresnel reflection coefficients at two orthogonal
% (here circular) polarization for GPS signals from a multi-layered plane medium
% Uses an approach developed by I. M. Fuks and A. G. Voronovich, 
% Wave diffraction by rough interfaces in an arbitrary plane-layered medium,
% Waves in Random Media, vol.10, No.2, pp. 253 - 272, 2000.
% Units:
%
% Description of variables:
%   The medium is composed of (nl-2) layers, separated by (nl-1) plane interfaces,
% 	with two half-spaces, above and below them, with eps(i), i from 1 to n
% 	i = 1 corresponds to the bottom half-space medium with eps = eps(1)
% 	i = nl corresponds to the top half-space with eps = eps(nl) 
%   depth in m;
%This script calls the following functions/scripts:
% eps_mlm
%==========================================================================

function [H_rc,V_rc,LH_rc,RH_rc] = refl_mlm(Depth,nl,re_epsil,im_epsil,fr,angle)
% fprintf('refl_mlm = %g \n');   
%-----------------------------------------------
	%c = 3.d8 ;  % m/s
    c = get_standard_constant('c');
	lambda = c/fr; 	kw=2*pi/lambda;   
     	 
    eps = zeros(nl,1);
	%%%eps(nl) = 1.0;     %dielectric permittivity of air
    eps(nl) = re_epsil(nl)+1i*im_epsil(nl);  % user-defined now.
    
    si=sin(pi*angle/180.);        
              % We start from the bottom layer 1
   eps(1) = re_epsil(1)+1i*im_epsil(1);
   eps(2) = re_epsil(2)+1i*im_epsil(2);
   
  %si1 = (si/sqrt(eps(1))); si2 = (si/sqrt(eps(2))); 
   	sq1h = sqrt(eps(1)- eps(nl)*si.^2);
    sq2h = sqrt(eps(2)- eps(nl)*si.^2);
	rbh= (sq2h - sq1h)./(sq2h + sq1h);
    sq1v = eps(2)*sq1h;
    sq2v = eps(1)*sq2h;
    rbv= (sq2v - sq1v)./(sq2v + sq1v);
%-----------------------------------------
        for m=2:nl-1
            %if(m==nl-1) eps(m+1)= 1.0;  % user-defined now.
            % else
   eps(m)   = re_epsil(m)  +1i*im_epsil(m);
   eps(m+1) = re_epsil(m+1)+1i*im_epsil(m+1);
            %end
%               disp(m); disp(eps(m+1))
    sq1h = sqrt(eps(m)  -eps(nl)*si.^2);
    sq2h = sqrt(eps(m+1)-eps(nl)*si.^2);
	rth= (sq2h - sq1h)./(sq2h + sq1h);
	sq1v = eps(m+1).*sq1h;
    sq2v = eps(m).*sq2h;
    rtv= (sq2v - sq1v)./(sq2v + sq1v);

    	%dz = Depth(m)-Depth(m+1);    % WRONG!!!
        dz = Depth(m-1)-Depth(m);
        psi=2.d0.*kw.*dz.*sq1h;
        q = exp(1i*psi);
        rbh= (rth + rbh.*q)./(1. + rth.*rbh.*q);
		rbv= (rtv + rbv.*q)./(1. + rtv.*rbv.*q);
        end
        
%-----------------------------------------------------------
%	Direct polarization reflection coefficient 
%	(indices should be read from right to left):
%	 rc(1) - HR (R to H),  rc(2) - VR (R to V)  
%    rc(3) - LR (R to L),  rc(4) - RR (R to R) 

%	 rc(1) = rbh/sqrt(2.0); rc(2) = -i*rbv/sqrt(2.0);
	 LH_rc = 0.5*(rbv-rbh); 
     RH_rc = 0.5*(rbh+rbv);
     H_rc = rbh;
     V_rc = rbv;

     
