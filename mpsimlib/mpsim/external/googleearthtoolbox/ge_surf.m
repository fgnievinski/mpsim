function kmlStr = ge_surf(x,y,z,varargin)
%
% ge_surf(x,y,z,varargin)
% Reference page in help browser: 
% <a href="matlab:web(fullfile(ge_root,'html','ge_surf.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


AuthorizedOptions = authoptions( mfilename );


if isempty(x)||isempty(y)
    error('empty coordinates passed to ge_imagesc().');
elseif isempty(z) 
    error('Empty data array passed to ge_imagesc().');    
end

           id = 'imagesc';
   visibility = 1;
    lineColor = '00000000';
%     timeStamp = ' ';
timeSpanStart = ' ';
 timeSpanStop = ' ';
    lineWidth = 0.25;
     snippet = ' ';
     description = '';
     altitude = 1.0;
      extrude = 0;
 altitudeMode = 'relativeToGround';
  msgToScreen = 0;
    polyAlpha = 'ff';
         cMap = 'jet';
   tessellate = 1;
       region = ' ';
%      cLimHigh: see further down
%       cLimLow: see further down
vertExagg = 1e4;
altRefLevel = 0; 

checkMateX = size(x);
checkMateY = size(y);
checkMateZ = size(z);

if checkMateX(1) ~= checkMateX(2) && checkMateY(1) ~= checkMateY(2)
    x = repmat(x,length(x),1);
    y = repmat(y,length(y),1)';
end

if checkMateZ(1) ~= checkMateZ(2)
    z = repmat(z,length(z),1);
end
    
  
dy = y(2:end)-y(1:end-1);
dx = x(2:end)-x(1:end-1);
% if any(abs(dy(2:end)-dy(1:end-1))>1e-12)||any(abs(dx(2:end)-dx(1:end-1))>1e-12)
%     error(['Function ' 39 mfilename 39 ' does not allow varying grid cell size.'])
% end
% clear dx dy
xResolution = abs(x(1,2)-x(1,1));
yResolution = abs(y(2)-y(1));

parsepairs %script that parses Parameter/Value pairs.

if msgToScreen
   disp(['Running ' mfilename '...']) 
end

if ~(isequal(altitudeMode,'clampToGround')||...
   isequal(altitudeMode,'relativeToGround')||...
   isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])
    
end   

if numel(xResolution)~=1
    error(['Function ',39,mfilename,39,': variable ',39,'xResolution',39,' should be scalar.'])
end

if numel(yResolution)~=1
    error(['Function ',39,mfilename,39,': variable ',39,'yResolution',39,' should be scalar.'])
end

if ~((length(x)>1)&&(length(y)>1))
    error(['Input variables ' 39 'x' 39 ' and ' 39 'y' 39 ' should at least contain 2 values.'])
end

if exist('nanValue','var')&&~isnan(nanValue)
    z(z==nanValue)=NaN;
end
if ~exist('cLimHigh','var')
    cLimHigh = max(z(:));
end
if ~exist('cLimLow','var')
    cLimLow = min(z(:));
end

if region == ' '
	region_chars = '';
else
	region_chars = [ region, 10 ];
end


halfLonRes = 0.5*xResolution;     
halfLatRes = 0.5*yResolution;

RIx = round(rand*10000);
C=[];
figure(RIx)
eval(['C = colormap(' cMap '(100));']);
close(RIx)
clear RIx

X = linspace(0,1,100)';
YRed = C(:,1);
YGreen = C(:,2);
YBlue = C(:,3);

kmlStr='';

for r=2:length(y(:,1))-1
    for c=2:length(x(1,:))-1
        
        if ~isnan(z(r,c))
            if isequal(polyAlpha,'00')
                hexColorStr = 'FFFFFF';
                newPolyAlpha = '00';
            else

                f = (z(r,c)-cLimLow)/(cLimHigh-cLimLow);

                if f<0
                    f=0;
                end
                if f>1
                    f=1;
                end

                YIRed = interp1(X,YRed,f);
                YIGreen = interp1(X,YGreen,f);
                YIBlue = interp1(X,YBlue,f);
                %hexColorStr = conv2colorstr(YIBlue,YIGreen,YIRed);
                hexColorStr = conv2colorstr(YIRed,YIGreen,YIBlue);
                newPolyAlpha = polyAlpha;
            end

            xv=[x(r,c)-halfLonRes;x(r,c)+halfLonRes;x(r,c)+halfLonRes;x(r,c)-halfLonRes];
            yv=[y(r,c)-halfLatRes;y(r,c)-halfLatRes;y(r,c)+halfLatRes;y(r,c)+halfLatRes];
            zv=det_altitude(x,y,z,r,c,vertExagg,halfLonRes,halfLatRes,altRefLevel);

               kmlStr = [kmlStr,ge_poly3(xv,yv,zv,...
                                           'snippet', snippet,...
                                           'description', description, ...
                                           'name',['row=',num2str(r),';col=',num2str(c)],...
                                      'polyColor',[newPolyAlpha,hexColorStr],...
                                    'description','',...
                                    'region', region,...
                                   'lineColor',lineColor,...
                                   'lineWidth',lineWidth,...
                               'timeSpanStart',timeSpanStart,...
                                'timeSpanStop',timeSpanStop,...
                                  'visibility',visibility,...
                                     'extrude',extrude,...
                                'altitudeMode',altitudeMode,...
                                  'tessellate',tessellate)];
        end
    end
end


if msgToScreen
   disp(['Running ' mfilename '...Done']) 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% local function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function S = conv2colorstr(B,G,R)
% Please note that this conv2colorstr is different from that in
% ge_colorbar. This one writes KML formatted hexadecimal 
% colorstrings, ge_colorbar() writes HTML formatted colorstr.


S='000000';

hexB = dec2hex(round(B*255));
hexG = dec2hex(round(G*255));
hexR = dec2hex(round(R*255));

LB = length(hexB);
LG = length(hexG);
LR = length(hexR);

S(3-LB:2)=hexB;
S(5-LG:4)=hexG;
S(7-LR:6)=hexR;


function ZVex = det_altitude(X,Y,DATA,R,C,vertExagg,halfLonRes,halfLatRes,altRefLevel)

% xi = X([C-1,C+1;C-1,C+1]);
% yi = Y([R-1,R-1;R+1,R+1]);
% Ix = sub2ind([length(Y),length(X)],[R-1,R-1;R+1,R+1],[C-1,C+1;C-1,C+1]);
% zi = DATA(Ix);
% 
% x0=[X(C)-halfLonRes;X(C)+halfLonRes;X(C)+halfLonRes;X(C)-halfLonRes];
% y0=[Y(R)-halfLatRes;Y(R)-halfLatRes;Y(R)+halfLatRes;Y(R)+halfLatRes];
% 
% ZVex(1:4,1)=interp2(xi,yi,zi*vertExagg+altRefLevel,x0,y0);
a = mean([DATA(R,C),DATA(R,C-1),DATA(R-1,C-1),DATA(R-1,C)]);
b = mean([DATA(R,C),DATA(R-1,C),DATA(R-1,C+1),DATA(R,C+1)]);
c = mean([DATA(R,C),DATA(R,C+1),DATA(R+1,C+1),DATA(R+1,C)]);
d = mean([DATA(R,C),DATA(R+1,C),DATA(R+1,C-1),DATA(R,C-1)]);
ZVex(1:4,1)=[a;b;c;d]*vertExagg+altRefLevel;