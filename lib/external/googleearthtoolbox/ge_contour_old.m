function [output] = ge_contour(x,y,data,varargin )
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_contour.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


AuthorizedOptions = authoptions(mfilename);

           id = 'contour';
        idTag = 'id';
         name = 'ge_contour';
    timeStamp = ' ';
timeSpanStart = ' ';
 timeSpanStop = ' ';
  description = '';
   visibility = 1;
    %lineColor = 'FFFFFFFF';
    lineWidth = 0.0;
      snippet = ' ';
     altitude = 1.0;
      extrude = 0;
   tessellate = 1;
 altitudeMode = 'relativeToGround';
  msgToScreen = false; 
  forceAsLine = true;
     numLevels = 15;
   lineValues = [];
    lineAlpha = 'FF';
       cMap   = 'jet';
       region = ' ';
    
parsepairs %script that parses Parameter/value pairs.

if msgToScreen
   disp(['Running ' mfilename '...']) 
end


if( isempty( x ) || isempty( y ) || isempty(data) )
    error('empty coordinates passed to ge_contour(...).');
end


if ~(isequal(altitudeMode,'clampToGround')||...
   isequal(altitudeMode,'relativeToGround')||...
   isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])
    
end

x1 = x(1,:);
if length(x1) == 1
    x1 = x(:,1);
end
y1 = y(:,1);
if length(y1) == 1
    y1 = y(1,:);
end

if isempty(lineValues)

    if numLevels <= 1
        C = contourc(x1,y1,data);
    else
        C = contourc(x1,y1,data,numLevels);
    end
else
    
    numLevels = length(lineValues);
    C = contourc(x1,y1,data,lineValues);
    
end



if altitude <= 0
    altitude = 1.0;
    disp('Resetting altitude to 1.0.')
end


i = 1;

X = C(1,:);
Y = C(2,:);

C1=[];

if ischar(cMap)

    RIx = round(rand*10000);
    figure(RIx)    
    eval(['C1 = colormap(' cMap '(256));']);
    close(RIx)
    clear RIx

else
    C1 = cMap;
end

X1 = linspace(0,1,size(C1,1))';
YRed = C1(:,1);
YGreen = C1(:,2);
YBlue = C1(:,3);


if ~exist('cLimHigh','var')
    cLimHigh = max(data(:));
end
if ~exist('cLimLow','var')
    cLimLow = min(data(:));
end

idxs = [];
idxCtr = 1;

while( i < length(C) )
   X(i)=NaN;
   Y(i)=NaN;
   idxs(idxCtr) = i;
   idxCtr = idxCtr + 1;
   count =  floor(C(2,i));
   i = i+count+1; 
end

output = '';
for i = 1:length(C)
    if isnan(X(i))

        idxp = find(idxs == i);
        idxp = idxp + 1;
        try
            idxp = idxs(idxp);
        catch
            idxp = length(C);
        end
        
        if exist('lineColor','var')
            hexColorStr = lineColor;
        else

            f = (C(1,i)-cLimLow)/(cLimHigh-cLimLow);

            if f<0
                f=0;
            end
            if f>1
                f=1;
            end

            YIRed = interp1(X1,YRed,f);
            YIGreen = interp1(X1,YGreen,f);
            YIBlue = interp1(X1,YBlue,f);

            hexColorStr = [lineAlpha,conv2colorstr(YIRed,YIGreen,YIBlue)];
        end

        output = [output ge_plot(X(i:idxp),Y(i:idxp),...
                'name',name, ...
                'snippet', snippet,...
                'description',description, ...
                'region', region, ...
                'timeStamp',timeStamp, ...
                'timeSpanStart',timeSpanStart, ...
                'timeSpanStop',timeSpanStop, ...
                'visibility',visibility, ...
                'lineColor',hexColorStr,...
                'lineWidth',lineWidth,...
                'altitude',altitude,...
                'altitudeMode',altitudeMode,...
                'extrude',extrude,...
                'tessellate',tessellate) ];

        count = floor(C(2,i));
        i = i+count+1;




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
