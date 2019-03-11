function varargout = ge_contour(x,y,z,varargin)
% Reference page in help browser:
%
% <a href="matlab:web(fullfile(ge_root,'html','ge_contourf.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a>
%


AuthorizedOptions = authoptions( mfilename );


id = 'contour';
idTag = 'id';
name = 'ge_contour';
timeStamp = ' ';
timeSpanStart = ' ';
timeSpanStop = ' ';
description = '';
visibility = 1;
lineColor = '';
lineAlpha = 'FF';
lineColorPolyMax = '00000000';
lineWidth = 0.25;
snippet = ' ';
extrude = 0;
tessellate = 1;
altitudeMode = 'clampToGround';
msgToScreen = false;
region   = ' ';
cMap = 'jet';
nearInf = abs(max(z(:))*10);
%       cLimHigh = max(max(z(2:end-1,2:end-1)));
%        cLimLow = min(min(z(2:end-1,2:end-1)));
altitude = 1.0;
polyAlpha = '00';
polyColor = '000000';
autoClose = true;
tinyRes = 1e-4;
lineValues = [];
numClasses = [];
numClassesDefault = 15;
cLimHigh = max(z(:));
cLimLow = min(z(:));

parsepairs %script that parses Parameter/value pairs.

minz = min(z(:));
maxz = max(z(:));


userSetsLineColor = ~strcmp(lineColor,'');
if userSetsLineColor
    lineColorUser = lineColor;
end
    
if isempty(numClasses)&~isempty(lineValues)
    if cLimHigh<maxz
        lineValues = unique([lineValues,maxz,nearInf]);
    else
        lineValues = unique([lineValues,nearInf]);
    end
elseif ~isempty(numClasses)&isempty(lineValues)
    if cLimHigh<maxz
        TMP = linspace(cLimLow,cLimHigh,numClasses+1);
        lineValues = [TMP(1:end),maxz,nearInf];
    else
        lineValues = [linspace(cLimLow,cLimHigh,numClasses+1),nearInf];
    end
elseif isempty(numClasses)&isempty(lineValues)
    % do nothing
else
    error('Cannot have both lineValues and numClasses')
end



% if cLimHigh<maxz
%     lineValues = [linspace(cLimLow,cLimHigh,numClasses+1),maxz,nearInf];
% else
%     lineValues = [linspace(cLimLow,cLimHigh,numClasses+1),nearInf];
% end


[nR,nC] = size(z);
tmp_z = ones([nR,nC]+2)*nearInf;
tmp_z(2:end-1,2:end-1) = z;
z = tmp_z;

if msgToScreen
    disp(['Running ' mfilename '...'])
end

if lineWidth==0
    lineColor='00000000';
end

if( isempty( x ) || isempty( y ) || isempty(z) )
    error('empty coordinates passed to ge_contour().');
end


if ~(isequal(altitudeMode,'clampToGround')||...
        isequal(altitudeMode,'relativeToGround')||...
        isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


if ndims(x)==2 && all(size(x)>1)
    xv = x(1,:);
else
    xv = x;
end

if ndims(y)==2 && all(size(y)>1)
    yv = y(:,1);
else
    yv = y;
end

dx = ((xv(end)-xv(1))/(numel(xv)-1))*tinyRes;
xv = [xv(1)-dx,xv,xv(end)+dx];
dy = ((yv(end)-yv(1))/(numel(yv)-1))*tinyRes;
yv = [yv(1)-dy;yv;yv(end)+dy];

contourArray = contourc(xv,yv,z,lineValues);


%save contourcresult.mat contourArray

if ischar(cMap)

    figHandles = get(0,'children');

    while true
        RIx = round(rand*1e9);
        if ~ismember(RIx,figHandles)
            figure(RIx)
            eval(['C1 = colormap(' cMap '(256));']);
            break
        end
    end
    close(RIx)
    clear RIx

else
    C1 = cMap;
end

X = linspace(0,1,size(C1,1))';
YRed = C1(:,1);
YGreen = C1(:,2);
YBlue = C1(:,3);



polyClosedThreshold = 1e-5; % Declare polygons closed when their start...
% and end points are separated by a distance...
% less than this value.

contourCell = parsecontarray(contourArray,nearInf);
% lineValuesMinMax = min(z(:));
%
% for k=1:size(contourCell,1)
%     lineValuesMinMax = [lineValuesMinMax;contourCell{k,1}];
% end
% lineValuesMinMax = unique([lineValuesMinMax(:);max(z(:))]);



% colorLevelInc = 0;
nRecords = size(contourCell,1);
isInnerArray=repmat(NaN,[nRecords,1]);
% aa=[]
kmlStr = '';
for m = 1:nRecords % my

    isInnerArray(:) = NaN;

    for o = [1:m-1,m+1:nRecords]

        % isinner(myRecord,otherRecord)
        isInnerArray(o,1)=isinner(contourCell(m,1:4),contourCell(o,1:4),lineValues);

    end

    if isclosed(contourCell(m,:),polyClosedThreshold)

        if hasouter(contourCell,m)
            colorLevelInc = 1;
        else
            colorLevelInc = 0;
        end

        levelDiff = abs(contourCell{m,1}-lineValues);
        colorLevel = find(levelDiff==min(levelDiff));
        colorDist = (cLimHigh-cLimLow);        
        if colorLevel==1|colorLevel==numel(lineValues)-1
            f = (mean(lineValues(colorLevel+colorLevelInc+[0]))-cLimLow)/colorDist;
%         elseif colorLevel==numel(lineValues)-1
%             f = (mean(lineValues(colorLevel+colorLevelInc+[1]))-cLimLow)/colorDist
        else
            f = (mean(lineValues(colorLevel+colorLevelInc+[0,1]))-cLimLow)/colorDist;
        end %colorLevel==1

        if f<0
            f=0;
        end
        if f>1
            f=1;
        end

        YIRed = interp1(X,YRed,f);
        YIGreen = interp1(X,YGreen,f);
        YIBlue = interp1(X,YBlue,f);
        if userSetsLineColor
            lineColor = [lineAlpha,lineColorUser];
        else
            lineColor = [lineAlpha,conv2colorstr(YIRed,YIGreen,YIBlue)];
        end
        %             polyColorCell{colorLevel+colorLevelInc,1} = polyColor;
        innerBoundsStr = ''; %buildinnerstr(contourCell,isInnerArray,altitude);

        if colorLevel+colorLevelInc==1
            colorClassStr = sprintf('less than %f',lineValues(colorLevel));
            actualLineColor = lineColor;
        elseif colorLevel+colorLevelInc>=numel(lineValues)-2
            colorClassStr = sprintf('more than %f',lineValues(colorLevel-1));
            actualLineColor = lineColorPolyMax;
            %actualLineColor = lineColor;
        else
            colorClassStr = sprintf('%f-%f',lineValues(colorLevel+colorLevelInc-1),lineValues(colorLevel+colorLevelInc));
            actualLineColor = lineColor;
        end

        kmlStr=[kmlStr,ge_poly(contourCell{m,3},contourCell{m,4},...
            'altitude',altitude,...
            'innerBoundsStr',innerBoundsStr,...
            'lineColor',actualLineColor,...
            'lineWidth',lineWidth,...
            'polyColor',[polyAlpha,lineColor(3:8)],...
            'autoClose',autoClose,...
            'region', region, ...
            'timeSpanStart',timeSpanStart,...
            'timeSpanStop',timeSpanStop,...
            'altitudeMode',altitudeMode,...
            'tessellate',tessellate,...
            'extrude',extrude,...
            'visibility',visibility,...
            'name',colorClassStr)];
    else
        warning(['Contour line record in ',39,'contourCell{',...
            num2str(m),',1}',39,' skipped',10,...
            'because it is not closed.'])
    end
    %     end
end

% save contourcell.mat contourCell
% figure
% for k=1:size(contourCell,1)
%     plot(contourCell{k,3},contourCell{k,4},'-k.')
%     hold on
% end
%

if nargout==1
    varargout{1} = kmlStr;
elseif nargout==2
    varargout{1} = kmlStr;
    varargout{2} = polyColorCell;
else
end

% aa


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % %      LOCAL FUNCTIONS START HERE       % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %



function A = parsecontarray(C,nearInf)

% column 1: level
% column 2: number of points
% column 3: xcoords
% column 4: ycoords

curCol = 1;
n = 1;

while curCol<size(C,2)

    L = C(2,curCol);
    lineValue = C(1,curCol);
    if lineValue~=nearInf
        A{n,1} = C(1,curCol);
        A{n,2} = L;
        A{n,3} = C(1,curCol+1:curCol+L);
        A{n,4} = C(2,curCol+1:curCol+L);
        %lineValuesTmp(n,1) = C(1,curCol);
        n = n + 1;
    end

    curCol = curCol + L + 1;

end

%lineValues = unique(lineValuesTmp);


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function IO = isclosed(myRecord,thresholdDiff)

L = myRecord{1,2};
xDiff = [myRecord{1,3}(1),myRecord{1,4}(1)];
yDiff = [myRecord{1,3}(L),myRecord{1,4}(L)];

IO = all(abs(xDiff-yDiff)<thresholdDiff);

function IO = isinner(myRecord,otherRecord,lineValues)

% It seems that contourc sometimes rounds off in a weird way...therefore
% a tweak is necessary here, in order not to end up with empty 'myIndexVec'
% and 'otherIndexVec' variables.
% check whether adjacent levels are concerned:
% myIndexVec = find(lineValues==myRecord{1,1});
% otherIndexVec = find(lineValues==otherRecord{1,1});
TMP = unique(lineValues);
dTMP = TMP(2:end)-TMP(1:end-1);
smallestDist = min(unique(dTMP));
roundOffFactor = 100;

myRecordRound = round(myRecord{1,1}/(smallestDist/roundOffFactor))*...
    (smallestDist/roundOffFactor);
otherRecordRound = round(otherRecord{1,1}/(smallestDist/roundOffFactor))*...
    (smallestDist/roundOffFactor);

lineValuesRound = round(lineValues/(smallestDist/roundOffFactor))*...
    (smallestDist/roundOffFactor);

myIndexVec = find(lineValuesRound==myRecordRound);
otherIndexVec = find(lineValuesRound==otherRecordRound);


% firstTest = any(abs(myIndexVec-otherIndexVec)==[1,0]);
firstTest = ismember(myIndexVec-otherIndexVec,[-1,0,1]);

% check whether the points of otherRecord fall within those of myRecord.

if ~firstTest
    IO = false;
else
    IN = inpolygon(otherRecord{1,3},otherRecord{1,4},...
        myRecord{1,3},myRecord{1,4});
    secondTest = all(IN);
end

IO = firstTest && secondTest;


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


function innerBoundsStr=buildinnerstr(contourCell,isInnerArray,altitude)
innerBoundsStr='';
oIndex = find(isInnerArray==1)';

% clf
% for u=oIndex
%     plot(contourCell{u,3},contourCell{u,4},'-b')
%     hold on
%     axis image
% end

% initialize 'contained' array:
contained=~(triu(ones(numel(oIndex))).*tril(ones(numel(oIndex))));
if isempty(oIndex)
    iVec = [];
elseif numel(oIndex)==1
    iVec = oIndex(1);
else
    for i = 1:numel(oIndex)
        for j = [1:i-1,i+1:numel(oIndex)]

            u = oIndex(i);
            v = oIndex(j);
            if all(inpolygon(contourCell{u,3},contourCell{u,4},...
                    contourCell{v,3},contourCell{v,4}))
                contained(i,j) = 0;
            end
        end
    end
    iVec = oIndex(sum(contained,2)==numel(oIndex)-1);
end

for elem = iVec
    innerBoundsStr = [innerBoundsStr,...
        '<innerBoundaryIs>',char(10),...
        '   <LinearRing>',char(10),...
        '      <coordinates>',char(10),...
        sprintf('          %.16g,%.16g,%.16g \n',[contourCell{elem,3}',contourCell{elem,4}',...
        altitude*ones(size(contourCell{elem,4}'))]'),char(10),...
        '      </coordinates>',char(10),...
        '   </LinearRing>',char(10),...
        '</innerBoundaryIs>',char(10)];
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


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


function IO=hasouter(contourCell,myIndex)

nRecords = size(contourCell,1);

inVec=repmat(NaN,[nRecords,1]);
uVec=[1:myIndex-1,myIndex+1:nRecords];
for u=uVec
    if contourCell{u,1}==contourCell{myIndex,1}
        inVec(u) = all(inpolygon(contourCell{myIndex,3},contourCell{myIndex,4},...
            contourCell{u,3},contourCell{u,4}));
    else
        inVec(u) = false;
    end
end

IO=any(inVec(uVec));





