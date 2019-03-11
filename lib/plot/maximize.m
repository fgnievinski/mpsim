function maximize(fig,w,h,force)
% MAXIMIZE Size a window to fill the entire screen.
%
% maximize(HANDLE fig)
%  Will size the window with handle fig such that it fills the entire screen.
%

% Modification History
% ??/??/2001  WHF  Created.
% 04/17/2003  WHF  Found 'outerposition' undocumented feature.
%

% Original author: Bill Finger, Creare Inc.
% Free for redistribution as long as credit comments are preserved.
%

if (nargin < 1) || isempty(fig), fig=gcf; end
if (nargin < 2) || isempty(w), w=1; end
if (nargin < 3) || isempty(h), h=1; end
if (nargin < 4) || isempty(force), force=true; end

if force,  drawnow();  end
units=get(fig,'units');
set(fig,'units','normalized','outerposition',[(1-w)/2 (1-h)/2 w h]);
set(fig,'units',units);
if force,  drawnow();  end

% Old way:	
% These are magic numbers which are probably system dependent.
%dim=get(0,'ScreenSize')-[0 -5 0 72];

%set(fig,'Position',dim); 


