function C = complex2rgb (z, f)
  if (nargin < 2) || isempty(f),  f = 0;  end
  if isa(f, 'function_handle'),  C = f(z);  return;  end
  switch f
  case 0
    C = z2rgb(z);
  case {1,2,3,4,5,6,7}
    C = DColorColorFunctions(z, f);
    C = hsv2rgb(C);
  case 8
    siz = size(z);
    s = repmat(1, siz); %#ok<RPMT1>
    v = repmat(1, siz); %#ok<RPMT1>
    %temp = abs(z);  temp = temp ./ max(temp(:));  %temp = 1 - temp;
    %temp = z.*conj(z);  temp = temp ./ max(temp(:));  %temp = 1 - temp;
    %temp = z.*conj(z);  temp = temp ./ max(temp(:));  temp = decibel_power(temp);
    %temp = z.*conj(z);  temp = decibel_power(temp);  temp = normalize(temp);
    %temp = z.*conj(z);  temp = decibel_power(temp);  temp = normalize(temp, 90);
    %temp = z.*conj(z);  temp = normalize(temp, 99);
    temp = abs(z);  temp = normalize(temp, 95);
    %temp = 1+(1-temp) .* 10;
    %temp = 1-1.5*(1-temp);  temp(temp<0) = 0;
    %temp = 10*temp;  temp(temp>1) = 1;
    s = temp;
    h = anglepos(z)./(2*pi);
    C = cat(3, h, s, v);
    C = hsv2rgb(C);
  otherwise
    error('MATLAB:complex2rgb:unkFunc', 'Unknown function.');
  end
end

function out = anglepos (in)
    out = angle (in);
    idx = (out < 0);
    out(idx) = out(idx) + 2*pi;
end

% <http://www.mathworks.com/company/newsletters/news_notes/clevescorner/summer98.cleve.html>
function C = z2rgb(z)
%Z2RGB Complex variable color image.
%   Z2RGB(Z) maps a complex matrix into a full color image.
%   The mapping is due to John Richardson
%   See http://home1.gte.net/jrsr/complex.html.
%   Example:
%      [x,y] = meshgrid(-2:1/16:2); z = x+i*y;
%      image(z2rgb(F(z)))

r = abs(z);
a = sqrt(1/6)*real(z);
b = sqrt(1/2)*imag(z);
d = 1./(1+r.^2);
R = 1/2 + sqrt(2/3)*real(z).*d;
G = 1/2 - d.*(a-b);
B = 1/2 - d.*(a+b);
d = 1/2 - r.*d;
d(r<1) = -d(r<1);
C(:,:,1) = R + d;
C(:,:,2) = G + d;
C(:,:,3) = B + d;

end

% <http://www.mathworks.com/matlabcentral/fileexchange/29028>
function  CData = DColorColorFunctions(w,cFunction)
%Domain coloring functions for plotting complex data
%
% Transforms the complex data in the MxN matrix W into an MxNx3 array of
% RGB values using the algorithm selected by cFunction.  Subfunction used
% by dcolor.m.
%

%% Calculate the color data matrix in HSV space

% Get page size for ugly indexing operations
ps = numel(w); 

if cFunction == 1
    CData = cat(3,angle(w),abs(w),abs(w));
    % Shift H so that a 0 degree angle has an HSV hue of 0 (red)
    CData(CData(:,:,1)<0) = CData(CData(:,:,1)<0)+2*pi;
    % Normalize H to [0,1]
    CData(:,:,1) = CData(:,:,1)/(2*pi);
    % Compute saturation and brightness from modulus
    CData(:,:,2) = 1./(1+0.33*iplog10(CData(:,:,2)./10+1));
    CData(:,:,3) = 1 - 1./(1.1+25*iplog10(2*CData(:,:,3)+1));
    
elseif cFunction == 2
    CData = cat(3,angle(w),iplog10(abs(w)),zeros(size(w)));
    % Shift H so that a 0 degree angle has an HSV hue of 0 (red)
    CData(CData(:,:,1)<0) = CData(CData(:,:,1)<0)+2*pi;
    % Normalize H to [0,1]
    CData(:,:,1) = CData(:,:,1)/(2*pi);
    % Compute saturation and brightness from normalized modulus. Start with
    % log10(modulus).  Compute 2 and 98 percentiles, then compress data
    % outside of this range and normalize to [0,1].  This is then fed into
    % the S and V calculations.
    CData(ps+find(isinf(CData(:,:,2)))) = NaN;
    CData(:,:,3) = reshape(sort(CData((ps+1):(2*ps))),size(CData(:,:,2)));
    lastdat = 2*ps+find(isnan(CData(:,:,3)),1)-1;
    lastdat(isempty(lastdat)) = 3*ps;
    q = [0 100*(0.5:(lastdat-2*ps+1-0.5))./(lastdat-2*ps+1) 100]';
    x = [CData(2*ps+1); CData((2*ps+1):lastdat)'; CData(lastdat)];
    % 2 calls to interp1q with scalar xi are faster than 1 call with vector
    y(2) = interp1q(q,x,98);
    y(1) = interp1q(q,x,2);
    idx = ps+find(CData(:,:,2)<y(1));
    CData(idx) = y(1)+2/pi*(atan(CData(idx)-max(CData(idx))-.5)-atan(-.5));
    idx = ps+find(CData(:,:,2)>y(2));
    CData(idx) = y(2)+2/pi*(atan(CData(idx)-min(CData(idx))+.5)-atan(.5));
    CData(:,:,2) = (CData(:,:,2)-min(min(CData(:,:,2))))/...
                   (max(max(CData(:,:,2)))-min(min(CData(:,:,2))));
    % Calculate S and V using atan(), then normalize to [0.1,1)
    CData(:,:,3) = CData(:,:,2);
    CData(:,:,2) = 1 - atan(CData(:,:,2).^3 - 1);
    CData(:,:,2) = 0.89999*(CData(:,:,2)-min(min(CData(:,:,2))))/...
                   (max(max(CData(:,:,2)))-min(min(CData(:,:,2)))) + 0.1;
    CData(:,:,3) = atan((CData(:,:,3)+1).^3);
    CData(:,:,3) = 0.79999*(CData(:,:,3)-min(min(CData(:,:,3))))/...
                   (max(max(CData(:,:,3)))-min(min(CData(:,:,3)))) + 0.2;
    
elseif cFunction == 3
    CData = cat(3,angle(w),abs(w),abs(w));
    % Shift H so that a 0 degree angle has an HSV hue of 0 (red)
    CData(CData(:,:,1)<0) = CData(CData(:,:,1)<0)+2*pi;
    % Normalize H to [0,1]
    CData(:,:,1) = CData(:,:,1)/(2*pi);
    % Make dark:normal:light bands for every decade of modulus
    CData(ps+find(isinf(CData(:,:,2)))) = NaN;
    CData(:,:,2) = iplog10(CData(:,:,2)) - floor(iplog10(CData(:,:,2)));
    CData(:,:,2) = 10.^(CData(:,:,2));
    CData(:,:,3) = CData(:,:,2);
    CData(:,:,2) = atan(CData(:,:,2).^5);
    CData(:,:,2) = 0.59999*(CData(:,:,2)-min(min(CData(:,:,2))))/...
                   (max(max(CData(:,:,2)))-min(min(CData(:,:,2)))) + 0.4;
    CData(:,:,3) = 1-atan(((CData(:,:,3)/10).^10-1));
    CData(:,:,3) = 0.59999*(CData(:,:,3)-min(min(CData(:,:,3))))/...
                   (max(max(CData(:,:,3)))-min(min(CData(:,:,3)))) + 0.4;
    
elseif cFunction == 4
    CData = cat(3,abs(w),angle(w),angle(w));
    % Compute hue from normalized modulus
    CData(isinf(CData(:,:,1))) = NaN;
    CData(:,:,1) = 0.84999*(CData(:,:,1)-min(min(CData(:,:,1))))/...
                   (max(max(CData(:,:,1)))-min(min(CData(:,:,1))))+0.00001;
    % Use angle: [-pi,pi)
    CData(:,:,2) = (CData(:,:,2) + pi)/(2*pi);
    CData(:,:,3) = CData(:,:,2);
    CData(:,:,2) = 1-1./(1.01+19*iplog10(-CData(:,:,2)+2));
    CData(:,:,3) = 1-1./(1.01+19*iplog10(CData(:,:,3)+1));
    
elseif cFunction == 5
    CData = cat(3,abs(w),angle(w),angle(w));
    % Compute hue from normalized modulus
    CData(isinf(CData(:,:,1))) = NaN;
    CData(:,:,1) = 0.84999*(CData(:,:,1)-min(min(CData(:,:,1))))/...
                   (max(max(CData(:,:,1)))-min(min(CData(:,:,1))))+0.00001;
    % Use angle: [0,2*pi) 
    CData(ps+find(CData(:,:,2)<0)) = CData(ps+find(CData(:,:,2)<0))+2*pi;
    CData(:,:,2) = CData(:,:,2)/(2*pi);
    CData(:,:,3) = CData(:,:,2);
    CData(:,:,2) = 1-1./(1.0+39*iplog10(-CData(:,:,2)+2));
    CData(:,:,3) = 1-1./(1.0+39*iplog10(CData(:,:,3)+1));
               
elseif cFunction == 6
    CData = cat(3,angle(w),ones(size(w)),ones(size(w)));
    % Saturation and brightness are fixed at 1
    % Shift H so that a 0 degree angle has an HSV hue of 0 (red)
    CData(CData(:,:,1)<0) = CData(CData(:,:,1)<0)+2*pi;
    % Normalize H to [0,1]
    CData(:,:,1) = CData(:,:,1)/(2*pi);
               
elseif cFunction == 7             
    CData = cat(3,abs(w),ones(size(w)),ones(size(w)));
    % Saturation and brightness are fixed at 1
    % Compute hue from normalized modulus
    CData(:,:,1) = iplog10(CData(:,:,1)+1);
    CData(isinf(CData(:,:,1))) = NaN;
    CData(:,:,1) = 0.84999*(CData(:,:,1)-min(min(CData(:,:,1))))/...
                   (max(max(CData(:,:,1)))-min(min(CData(:,:,1))))+0.00001;

else
    % For invalid cFunction, call ourselves recursively with cFunction = 1
    CData = DColorColorFunctions(w,1);
    return
end

end

function x = iplog10(x)
x = log10(x);
%% In-place implementation of log10 for reduced memory use
%x = log2(x);
%x = x/6.64385618977472436 + x/6.64385618977472525;
end % End of function iplog10

