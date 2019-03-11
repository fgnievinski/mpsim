function clrstr=ge_color(c,varargin)
%GE_COLOR  Convert Matlab color/opacity to Google Earth hexadecimal string
%
%SYNTAX: ColorStr = ge_color(ColorSpec)
%        ColorStr = ge_color(ColorMat)
%        ColorStr = ge_color(Opacity)
%        ColorStr = ge_color(...,Opacity)
%
% where,
%    clrstr    = Google Earth color string
%    ColorSpec = Matlab color specification. E.g. 'r','b','k'
%    ColorMat  = Matlab-sytle rgb color matrix. E.g. [.35,.75,.25]
%    Opacity   = Opacity of object (0 to 1) (0=transparent, 1=opaque)
%
%EXAMPLES: 
% Specify color as red with Matlab ColorSpec
% >> ge_color('r')
% >> ans = 0000FF
% 
% Specify color as gray with Matlab color vector
% >> ge_color(0.7*[1,1,1])
% >> ans = B3B3B3
% 
% Specify opacity
% >> ge_color(.75)
% >> ans = BF
% 
% Specify color and opacity
% >> ge_color('m',.8)
% >> ans = CCFF00FF
% >> ge_color([1,0,0],.8)
% >> ans = CC0000FF

%Jarrell Smith
%3/4/2008

%% Parameters
opacity=1;
cspec=[0,0,0];

%% Check Input
nargchk(nargin,1,2);
%set opacity
if nargin==2,
   mode='both';
   opacity=varargin{1};
   if length(opacity)>1 || ~isnumeric(opacity),
      error('Opacity must be numeric and length 1')
   elseif opacity>1 || opacity<0,
      error('Opacity must be between 0-1')
   end
else
   mode='color';
end
%set color
if ischar(c), %process as color
   switch lower(c)
      case {'y','yellow'}
         cspec=[1,1,0];
      case {'m','magenta'}
         cspec=[1,0,1];
      case {'c','cyan'}
         cspec=[0,1,1];
      case {'r','red'}
         cspec=[1,0,0];
      case {'g','green'}
         cspec=[0,1,0];
      case {'b','blue'}
         cspec=[0,0,1];
      case {'w','white'}
         cspec=[1,1,1];
      case {'k','black'}
         cspec=[0,0,0];
      otherwise
         error('%s is an invalid Matlab ColorSpec.',c)
   end
elseif isnumeric(c) && ndims(c)==2, %Determine if Color or Opacity
   if  all(size(c)==[1,1]), %Input is Opacity
      if c>1 || c<0
         error('Opacity must be scalar quantity between 0 to 1')
      end
      opacity=c;
      mode='opacity';
   %color
   elseif all(size(c)==[1,3]) %Input is Color
      if any(c<0|c>1)
         error('Numeric ColorSpec must be size [1,3] with values btw 0 to 1.')
      end
      cspec=c;
   else
      error('Incorrect size of first input argument.  Size must be [1,3] or [1,1].')
   end
else
   error('Incorrect size of first input argument.  Size must be [1,3] or [1,1].')
end
%% Create Google Earth String
opacity=round(opacity*255); %transparency (Matlab format->KML format)
cspec=round(fliplr(cspec)*255); %color (Matlab format->KML format)
switch mode
   case 'color'
      clrstr=sprintf('%s%s%s',dec2hex(cspec,2)');
   case 'opacity'
      clrstr=sprintf('%s',dec2hex(opacity,2));
   case 'both'
      clrstr=sprintf('%s%s%s%s',dec2hex(opacity,2),dec2hex(cspec,2)');
end
