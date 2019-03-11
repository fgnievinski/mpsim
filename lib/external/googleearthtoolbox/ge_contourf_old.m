function [output] = ge_contourf_old(x,y,data,varargin )
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_contourf_old.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


if strcmp(devenv,'octave')
    warning('ge_contourf function not yet implemented for octave.')
    output='';
    return
end
    
AuthorizedOptions = authoptions( mfilename );

                            
           id = 'contourf';
        idTag = 'id';
         name = 'ge_contourf';
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
 altitudeMode = 'clampToGround';
  msgToScreen = false; 
  forceAsLine = true;
     numLevels = 1;
   lineValues = [];
    polyAlpha = 'FF';
       cMap   = 'jet';
       output = '';
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

RIx = round(rand*10000);
C1=[];
figure(RIx)
if isempty(lineValues)

    if numLevels <= 1
        [C,h,CF] = contourf(x1,y1,data);
    else
        [C,h,CF] = contourf(x1,y1,data,numLevels);
    end
else
    
    numLevels = length(lineValues);
    [C,h,CF] = contourf(x1,y1,data,lineValues);
    
end
close(RIx)


totalArea = polyarea( [x1(1) x1(1) x1(end) x1(end)], [y1(1) y1(end) y1(end) y1(1)] );
midVal = median(data(~isnan(data)));
minVal = min(data(~isnan(data)));
D = parseC( CF, midVal, totalArea );


if altitude <= 0
    altitude = 1.0;
    disp('Resetting altitude to 1.0.')
end


i = 1;

% X = C(1,:);
% Y = C(2,:);
% 
% 
RIx = round(rand*10000);
C1=[];
figure(RIx)
eval(['C1 = colormap(' cMap '(100));']);
close(RIx)
clear RIx
X1 = linspace(0,1,100)';
YRed = C1(:,1);
YGreen = C1(:,2);
YBlue = C1(:,3);


if ~exist('cLimHigh','var')
    cLimHigh = max(data(:));
end
if ~exist('cLimLow','var')
    cLimLow = min(data(:));
end


while( i < length(D.value) )

    
        f = (D.value(i)-cLimLow)/(cLimHigh-cLimLow);

        if f<0
            f=0;
        elseif f>1
            f=1;
        end

        YIRed = interp1(X1,YRed,f);
        YIGreen = interp1(X1,YGreen,f);
        YIBlue = interp1(X1,YBlue,f);
        hexColorStr = conv2colorstr(YIBlue,YIGreen,YIRed);
        newPolyAlpha = polyAlpha;
        
        
        output = [output ge_poly(D.x{i},D.y{i},...
                'name',name, ...
                'snippet', snippet,...
                'description',description, ...
                'region', region, ...
                'timeStamp',timeStamp, ...
                'timeSpanStart',timeSpanStart, ...
                'timeSpanStop',timeSpanStop, ...
                'visibility',D.visibility(i), ...
                'polyColor',[newPolyAlpha,hexColorStr],... 
                'lineColor',[newPolyAlpha,hexColorStr],... 
                'lineWidth',lineWidth,...
                'altitude',altitude+D.level(i),...
                'altitudeMode',altitudeMode,...
                'autoClose',false,...
                'extrude',extrude,...
                'tessellate',tessellate) ];

    i = i + 1;
end


if msgToScreen
   disp(['Running ' mfilename '...Done']) 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% local functions
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


function [D] = parseC( C, midVal, totalArea )


    D = struct;
  
    idxCtr = 1;
    i = 1;


    while( i < length(C) )

        value = C(1,i);
        count =  floor(C(2,i)); %num of entries        
        
        D.idxBegin(idxCtr) = i+1;
        D.idxEnd(idxCtr) = i+count;
        D.value(idxCtr) = value;
        D.count(idxCtr) = count;
        D.x{idxCtr} = C(1,D.idxBegin(idxCtr):D.idxEnd(idxCtr));
        D.y{idxCtr} = C(2,D.idxBegin(idxCtr):D.idxEnd(idxCtr));
        
        %visibility decision... is layer suitable?
        D.testArea(idxCtr) = polyarea(D.x{idxCtr},D.y{idxCtr});    
        D.visibility(idxCtr) = D.testArea(idxCtr) <= totalArea;
        
%         if idxCtr == 31
%             keyboard;
%         end
        if D.value(idxCtr) >= midVal
            D.level(idxCtr) = 2 * abs(midVal+D.value(idxCtr));
        else
            D.level(idxCtr) = abs(midVal+D.value(idxCtr));
        end

        idxCtr = idxCtr + 1;
        i = i+count+1; 
        
    end
    
    %put the midpoint plane in if exists...
    midPlane = D.testArea > totalArea ;
    if sum(midPlane) > 0
        minVal = min(D.testArea(midPlane));
        idx = find( D.testArea == minVal );
        D.visibility(idx) = true;
    end
    

    
        
            

