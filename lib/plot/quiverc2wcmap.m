 function hh = quiverc2wcmap(varargin)
 % function hh = quiverc2wcmap(varargin)
% Andrew Diamond 3/17/2005
% This is based off of Tobias Höffken which was based off of Bertrand Dano
% keeping with their main intent to show a color w/r to magnitude quiver plot
% while maintaining a large amount of quiver API backwards compatability.
% Functional differences from quiverc2:
%   1) This works under 6.5.1
%   2) It handles NaNs
%   3) It draws a colormap that is w/r to the quiver magnitudes (hard coded to
%   20 segments of the colormap as per quiverc2 - seems fine for a quiver).
%   4) Various bug fixes (I think )
% In order to do this I needed some small hacks on 6.5.1's quiver to take a
% color triplet.  I have included as part of this file in a subfunciton below.
%----------------
% Rest of comments from quiverc2
% changed Tobias Höffken 3-14-05
% totally downstripped version of the former
% split input field into n segments and do a quiver qhich each of them 
 
% Modified version of Quiver to plots velocity vectors as arrows 
% with components (u,v) at the points (x,y) using the current colormap 

% Bertrand Dano 3-3-03
% Copyright 1984-2002 The MathWorks, Inc. 

% changed T. Höffken 14.03.05, for high data resolution
% using fixed color "spacing" of 20

%QUIVERC Quiver color plot.
%   QUIVERC(X,Y,U,V) plots velocity vectors as arrows with components (u,v)
%   at the points (x,y).  The matrices X,Y,U,V must all be the same size
%   and contain corresponding position and velocity components (X and Y
%   can also be vectors to specify a uniform grid).  QUIVER automatically
%   scales the arrows to fit within the grid.
%
%   QUIVERC(U,V) plots velocity vectors at equally spaced points in
%   the x-y plane.
%
%   QUIVERC(U,V,S) or QUIVER(X,Y,U,V,S) automatically scales the 
%   arrows to fit within the grid and then stretches them by S.  Use
%   S=0 to plot the arrows without the automatic scaling.
%
%   QUIVERC(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVERC(...,'filled') fills any markers specified.
%
%   H = QUIVERC(...) returns a vector of line handles.
%
%   Example:
%      [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%      z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%      contour(x,y,z), hold on
%      quiverc(x,y,px,py), hold off, axis image
%
%   See also FEATHER, QUIVER3, PLOT. 
%   Clay M. Thompson 3-3-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.21 $  $Date: 2002/06/05 20:05:16 $ 
%-------------------------------------------------------------
n=20; %# of colors
%n=50;

nin = nargin;

%error(nargchk(2,5,nin));
error(nargchk(2,6,nin));

% Check numeric input arguments
if nin<4, % quiver(u,v) or quiver(u,v,s)
  [msg,x,y,u,v] = xyzchk(varargin{1:2});
else
  [msg,x,y,u,v] = xyzchk(varargin{1:4});
end
if ~isempty(msg), error(msg); end

if(nin == 6),  nin = 5;  end
scale=1; % %This is the default I think.
if(nin == 3 | nin == 5)
    if(isscalar(varargin{nin}))
        scale = varargin{nin};
    end
end


%----------------------------------------------
% Define colormap 
vr = sqrt(u.^2+v.^2); % matrix of magnitudes of data
CC = colormap;
%--- commented out from quiverc2 -------------------------------------------
% scaled and ceiled matrix of magnitues so as to linearly scale them from 1:n so
% that they can be used and indicies into an n element array where n is defined
% (above) as being the number of colors;
% colit = ceil(((vr-min(vr(:)))./(max(vr(:))-min(vr(:))))*n);


%--- commented out from quiverc2 -------------------------------------------
% each ucell and vcell will cotain the portio of the data that corresponds to
% one of the n color bands (the 20 below should be a n) 
% ucell = cell(n,1);
% vcell = cell(n,1);
% for it=(1:1:n) % initialize values to NaN
%     ucell{it}=ones(size(u))*NaN;
%     vcell{it}=ones(size(u))*NaN;    
% end

% if data has Nan, don't let it contaminate the computations that segement the
% data;  I could just do this with vr and then get clever with the indices but
% this make for easy debugging and as this is a graphics routine the compuation
% time is completely irrelavent.
nonNaNind = find(~isnan(vr(:)));
xyuvvrNN = [x(nonNaNind),y(nonNaNind),u(nonNaNind),v(nonNaNind),vr(nonNaNind)];
[xyuvvrNNs, xyuvvrNNsi] = sortrows(xyuvvrNN,5);

iCCs=round(linspace(1,size(CC,1),n));
iData = round(linspace(0,size(xyuvvrNNs,1),n+1));
%figure;

% -------------------
% Setup for a colormap?  Well, first, there must be a better way but anyway
% (at least in 6.5.1) if you ever want a colorbar tick marks to reflect real data ranges
% (versus just the indices of a colormap) then there apparently has to be an
% image somewhere in the figure.  Of course, I don't want an image but I figured
% I just make it invisible and then draw the quiver plot over it.
% Unfortunately, it seems that colorbar uses caxis to retrive the data range in
% the image and for invisible images it always seems to be 0 UNLESS you
% explictly reset the caxis.  Go figure (no pun intended).  Yeah, I would trust this, uhhuh (-;
% This will work but then the axis will be oversized to accomodate the image
% because images have their first and last vitual "pixels" CENTERED around the
% implicit or explict xmin,xmax,ymin,ymax (as per imagesc documentation) but the
% start and end of each of these "pixels" is +/- half a unit where the unit
% corresponds to subdividing the limits by the number of pixels (-1).  Given
% that formula and given my invisible 2x2 image for which it is desired to
% diplay in an axis that ISN'T oversized (i.e. min(x), max(x), min(y),max(y)) it
% is possible to solve for the limits (i.e. an artifically reduced limit) 
% that need to be specified for imagesc to make it's final oversized axis to be the 
% non oversized axis that we really want.
% xa,xb,ya,yb compenstates for the axis extention given by imagesc to make
% pixels centered at the limit extents (etc.).  Note, this "easy"
% formula would only work for 2x2 pixel images.
xs = x(1);
xf = x(end);
xa = (3 * xs + xf)/4;
xb = (3 * xf + xs)/4;

ys = y(1);
yf = y(end);
ya = (3 * ys + yf)/4;
yb = (3 * yf + ys)/4;
h=imagesc([xa,xb],[ya,yb],reshape(xyuvvrNNs([1,end;1,end],5),2,2));
set(h,'visible','off');
caxis(xyuvvrNNs([1,end],5));
hold on;
scale
for it=1:n
    c = CC(iCCs(it),:);
    si = iData(it)+1;
    ei = iData(it+1);
    %hh=quiver(xyuvvrNNs(si:ei,1),xyuvvrNNs(si:ei,2),xyuvvrNNs(si:ei,3),xyuvvrNNs(si:ei,4),scale,'Color',c);
    hh=quiver(xyuvvrNNs(si:ei,1),xyuvvrNNs(si:ei,2),xyuvvrNNs(si:ei,3),xyuvvrNNs(si:ei,4),scale*it/n,'Color',c);
end    
if (nargout == 0),  clear hh;  end

colorbar;
%--- commented out from quiverc2 -------------------------------------------
% for jt=(1:1:length(u))
%     %it = ceil(((vr(jt)-min(vr(:)))/(max(vr(:))-min(vr(:))))*n);
%     ucell{min(n,max(colit(jt),1))}(jt) = u(jt);
%     vcell{min(n,max(colit(jt),1))}(jt) = v(jt);
% end
% 
% figure;
% hold on;
% 
% 
% for it=(1:1:n)
%     c = CC(ceil(it/n*64),:);
%     hh=quiver(x,y,ucell{it},vcell{it},scale*it/n,'Color',c);
%     hold on;
% end
% 


%-------------------------------
% This is Matlab's 6.5.1 quiver.  I figure that ensures a fair amouint of backward
% compatibility but I needed to hack it to allow a 'Color' property.  Obviously
% a person could do more.
    
function hh = quiver(varargin)
%QUIVER Quiver plot.
%   QUIVER(X,Y,U,V) plots velocity vectors as arrows with components (u,v)
%   at the points (x,y).  The matrices X,Y,U,V must all be the same size
%   and contain corresponding position and velocity components (X and Y
%   can also be vectors to specify a uniform grid).  QUIVER automatically
%   scales the arrows to fit within the grid.
%
%   QUIVER(U,V) plots velocity vectors at equally spaced points in
%   the x-y plane.
%
%   QUIVER(U,V,S) or QUIVER(X,Y,U,V,S) automatically scales the 
%   arrows to fit within the grid and then stretches them by S.  Use
%   S=0 to plot the arrows without the automatic scaling.
%
%   QUIVER(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVER(...,'filled') fills any markers specified.
%
%   H = QUIVER(...) returns a vector of line handles.
%
%   Example:
%      [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%      z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%      contour(x,y,z), hold on
%      quiver(x,y,px,py), hold off, axis image
%
%   See also FEATHER, QUIVER3, PLOT.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.21 $  $Date: 2002/06/05 20:05:16 $

% Arrow head parameters
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length
autoscale = 1; % Autoscale if ~= 0 then scale by this.
plotarrows = 1; % Plot arrows
sym = '';

filled = 0;
ls = '-';
ms = '';
col = 'b';

nin = nargin;
ColorSpecInd = find(strcmpi(varargin, 'color'));
if(length(ColorSpecInd)==1 & nin > ColorSpecInd)
    col = varargin{ColorSpecInd+1};
    varargin = varargin([1:ColorSpecInd-1,ColorSpecInd+2:nin]);
    nin = nin-2;
end
% Parse the string inputs
while isstr(varargin{nin}),
  vv = varargin{nin};
  if ~isempty(vv) & strcmp(lower(vv(1)),'f')
    filled = 1;
    nin = nin-1;
  else
    [l,c,m,msg] = colstyle(vv);
    if ~isempty(msg), 
      error(sprintf('Unknown option "%s".',vv));
    end
    if ~isempty(l), ls = l; end
    if ~isempty(c), col = c; end
    if ~isempty(m), ms = m; plotarrows = 0; end
    if isequal(m,'.'), ms = ''; end % Don't plot '.'
    nin = nin-1;
  end
end

error(nargchk(2,5,nin));

% Check numeric input arguments
if nin<4, % quiver(u,v) or quiver(u,v,s)
  [msg,x,y,u,v] = xyzchk(varargin{1:2});
else
  [msg,x,y,u,v] = xyzchk(varargin{1:4});
end
if ~isempty(msg), error(msg); end

if nin==3 | nin==5, % quiver(u,v,s) or quiver(x,y,u,v,s)
  autoscale = varargin{nin};
end

% Scalar expand u,v
if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end

if autoscale,
  % Base autoscale value on average spacing in the x and y
  % directions.  Estimate number of points in each direction as
  % either the size of the input arrays or the effective square
  % spacing if x and y are vectors.
  if min(size(x))==1, n=sqrt(prod(size(x))); m=n; else [m,n]=size(x); end
  delx = diff([min(x(:)) max(x(:))])/n;
  dely = diff([min(y(:)) max(y(:))])/m;
  del = delx.^2 + dely.^2;
  if del>0
    len = sqrt((u.^2 + v.^2)/del);
    maxlen = max(len(:));
  else
    maxlen = 0;
  end
  
  if maxlen>0
    autoscale = autoscale*0.9 / maxlen;
  else
    autoscale = autoscale*0.9;
  end
  u = u*autoscale; v = v*autoscale;
end

ax = newplot;
next = lower(get(ax,'NextPlot'));
hold_state = ishold;

% Make velocity vectors
x = x(:).'; y = y(:).';
u = u(:).'; v = v(:).';
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];

% h1 = plot(uu(:),vv(:),[col ls]);
h1 = plot(uu(:),vv(:),ls,'Color',col);

if plotarrows,
  % Make arrow heads and plot them
  hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
        x+u-alpha*(u-beta*(v+eps));repmat(NaN,size(u))];
  hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
        y+v-alpha*(v+beta*(u+eps));repmat(NaN,size(v))];
  hold on
 %  h2 = plot(hu(:),hv(:),[col ls]);
  h2 = plot(hu(:),hv(:),ls,'Color',col);
else
  h2 = [];
end

if ~isempty(ms), % Plot marker on base
  hu = x; hv = y;
  hold on
%  h3 = plot(hu(:),hv(:),[col ms]);
  h3 = plot(hu(:),hv(:),ls,'Color',col);
  if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
  h3 = [];
end

if ~hold_state, hold off, view(2); set(ax,'NextPlot',next); end

if nargout>0, hh = [h1;h2;h3]; end

    

function retval = isscalar(m)
retval = prod(size(m)) == 1;
