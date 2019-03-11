function [kmlStr] = ge_imagesc_old(x,y,data,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_imagesc_old.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%



AuthorizedOptions = authoptions( 'ge_imagesc_old' );


if isempty(x)||isempty(y)
    error('empty coordinates passed to ge_imagesc().');
elseif isempty(data) 
    error('Empty data array passed to ge_imagesc().');    
end

           id = 'imagesc';
%       idTag = 'id';
   visibility = 1;
    lineColor = '00000000';
    timeStamp = ' ';
timeSpanStart = ' ';
 timeSpanStop = ' ';
    lineWidth = 0.25;
      snippet = ' ';
     altitude = 1.0;
      extrude = 0;
 altitudeMode = 'clampToGround';
  msgToScreen = 0;
    polyAlpha = 'ff';
         cMap = 'jet';
dataFormatStr = '%g';  
   tessellate = 1;
     region = ' ';
%      cLimHigh: see further down
%       cLimLow: see further down

  
dy = y(2:end)-y(1:end-1);
dx = x(2:end)-x(1:end-1);
% if any(abs(dy(2:end)-dy(1:end-1))>1e-12)||any(abs(dx(2:end)-dx(1:end-1))>1e-12)
%     error(['Function ' 39 mfilename 39 ' does not allow varying grid cell size.'])
% end
% clear dx dy
xResolution = abs(x(2)-x(1));
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
    data(data==nanValue)=NaN;
end
if ~exist('cLimHigh','var')
    cLimHigh = max(data(:));
end
if ~exist('cLimLow','var')
    cLimLow = min(data(:));
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

%preallocate the kmlStr variable with percent signs:
kmlStr=char(37*ones(1,numel(x)*numel(y)*1000)); 
n=0;
for r=1:length(y)
    for c=1:length(x)
        if ~isnan(data(r,c))
            if isequal(polyAlpha,'00')
                hexColorStr = 'FFFFFF';
                newPolyAlpha = '00';
            else

                f = (data(r,c)-cLimLow)/(cLimHigh-cLimLow);

                if f<0
                    f=0;
                end
                if f>1
                    f=1;
                end

                YIRed = interp1(X,YRed,f);
                YIGreen = interp1(X,YGreen,f);
                YIBlue = interp1(X,YBlue,f);
                hexColorStr = conv2colorstr(YIBlue,YIGreen,YIRed);
                newPolyAlpha = polyAlpha;

                TMP = ge_box(x(c)-halfLonRes,x(c)+halfLonRes,...
                            y(r)-halfLatRes,y(r)+halfLatRes,...
                                'name',['row=',num2str(r),';col=',num2str(c)],...
                           'polyColor',[newPolyAlpha,hexColorStr],...
                           'snippet', snippet,...
                           'region', region, ...
                         'description',['<TABLE border=1><TR><TD align=',34,'right',34,'>row</TD>',...
                                                         '<TD align=',34,'left',34,'>',int2str(r),'</TD></TR>',...
                                                     '<TR><TD align=',34,'right',34,'>column</TD>',...
                                                         '<TD align=',34,'left',34,'>',int2str(c),'</TD></TR>',...
                                                     '<TR><TD align=',34,'right',34,'>data(r,c)</TD>',...
                                                         '<TD align=',34,'left',34,'>',num2str(data(r,c),dataFormatStr),'</TD></TR>',...
                                      '</TABLE>'],...
                        'lineColor',lineColor,...
                        'lineWidth',lineWidth,...
                        'timeStamp',timeStamp,...
                    'timeSpanStart',timeSpanStart,...
                     'timeSpanStop',timeSpanStop,...
                       'visibility',visibility,...
                         'altitude',altitude,...
                          'extrude',extrude,...
                     'altitudeMode',altitudeMode,...
                       'tessellate',tessellate);

               kmlStr(n+1:n+length(TMP))=TMP;
               n = n+length(TMP);
            end
        end           
    end
end
kmlStr(n+1:end)='';
% clear k
% for k = length(kmlStr):-1:1
%     if ~strcmp(kmlStr(k),'%')
%         break
%     end
% end
% kmlStr=kmlStr(1:k);



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