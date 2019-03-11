function kmlStr = ge_axes(varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_axes.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


AuthorizedOptions = authoptions( mfilename );

   altitudeMode = 'relativeToGround';
      lineWidth = 1;
      lineColor = '40FFFFFF';
      msgToScreen = false;
      region = ' ';
%    xyLineColor
%    yzLineColor
%    xzLineColor
%    hLineColor
%    tLineColor
%    rLineColor
%    hAxisLength
%    tAxisLength
%    rAxisLength


parsepairs  

if msgToScreen
    disp(['Running: ',mfilename,'...'])
end

if ~all(ismember(axesType,'xyzh'))
   error(['Function: ' mfilename ' - Only ',39,'x',39,', ',39,'y',39,', ',39,...
          'z',39,', and ',39,'h',39,' are allowed in',10,'parameter ',39,'axesType',39,'.'])
end

if exist('xyLineColor','var')==0
    xyLineColor = lineColor;
end
if exist('yzLineColor','var')==0
    yzLineColor = lineColor;
end
if exist('xzLineColor','var')==0
    xzLineColor = lineColor;
end

if ~isempty(findstr(axesType,'h'))
    if exist('hLineColor','var')==0
        hLineColor = lineColor;
    end
    if exist('hAxisLength','var')==0
        error(['You should include parameter ',39,'hAxisLength',39,' in the call',10,'to function ',mfilename,'.'])
    end
end

if ~isempty(findstr(axesType,'x'))&&exist('xTick','var')==0 ||...
   ~isempty(findstr(axesType,'y'))&&exist('yTick','var')==0 ||...
   ~isempty(findstr(axesType,'z'))&&exist('zTick','var')==0 ||...
   ~isempty(findstr(axesType,'h'))&&exist('hTick','var')==0   
         error([mfilename,': You must specify tick positions for all axes',10,...
             'included in parameter ',39,'axesType',39,'.',10,...
             'See <a href="matlab:doc(',39,mfilename,39,')">doc ',mfilename,...
             '</a> for details.'])
end


if exist('axesType','var')==0
    error(['Inclusion of parameter ',39,'axesType',39,' is compulsory.'])
else
    L = length(axesType);
    if ~xor(ismember(L,[2,3]),isequal(axesType,'h'))
        error(['See <a href="matlab:doc(',39,mfilename,39,')">doc ',mfilename,'</a> for details on how to use',10,...
        'parameter ',39,'axesType',39,'.'])
    end
    clear L
end

if exist('axesOrigin','var')==0&&isequal('h',axesType)
    error(['Inclusion of parameter ',39,'axesOrigin',39,' is compulsory when',10,...
           'parameter ',39,'axesType',39,' is set to ',39,'h',39,'.'])
end

if sum(ismember('xyz',axesType))<=2&&exist('axesOrigin','var')==0
    error([mfilename, ': You need to specify parameter ',39,'axesOrigin',39,' .'])
else
    if exist('axesOrigin','var')==0
        if exist('xTick','var')
            axesOrigin(1)=min(xTick);
        end

        if exist('yTick','var')
            axesOrigin(2)=min(yTick);
        end

        if exist('zTick','var')
            axesOrigin(3)=min(zTick);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% start drawing Cartesian planes as specified %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


kmlStrXY='';
kmlStrXZ='';
kmlStrYZ='';

kmlStrH='';


if exist('xTick','var')&&~isempty(findstr('x',axesType))&&...
   exist('yTick','var')&&~isempty(findstr('y',axesType))
   
   %%% Draw xy-plane only:    
    XV = [];
    YV = [];
    ZV = [];    
    
    minY = min(yTick);
    maxY = max(yTick);
    
    for xT=1:length(xTick)
        XV = [XV;xTick(xT);xTick(xT);NaN];
        YV = [YV;minY;maxY;NaN];
    end

    minX = min(xTick);
    maxX = max(xTick);
    
    for yT=1:length(yTick)
        XV = [XV;minX;maxX;NaN];
        YV = [YV;yTick(yT);yTick(yT);NaN];
    end

    if isequal('altitudeMode','clampToGround')
        L = length(xTick)*3+length(yTick)*3;    
        ZV = [ZV;ones(L,1)];
        clear L
    else
        L = length(xTick)*3+length(yTick)*3;
        ZV = [ZV;ones(L,1)*axesOrigin(3)];
        clear L
    end
    
    kmlStrXY = ge_folder('xy-plane (ge_axes)',...
                ge_plot3(XV,YV,ZV,...
                   'altitudeMode',altitudeMode,...
                      'lineColor',xyLineColor,...
                      'lineWidth',lineWidth,...
                      'name','grid line'));
end

if exist('xTick','var')&&~isempty(findstr('x',axesType))&&...
   exist('zTick','var')&&~isempty(findstr('z',axesType))

   %%% Draw xz-plane only

    XV = [];
    YV = [];
    ZV = [];    

   % altitudeMode = 'relativeToGround';
    
    minZ = min(zTick);
    maxZ = max(zTick);
    
    for xT=1:length(xTick)
        XV = [XV;xTick(xT);xTick(xT);NaN];
        ZV = [ZV;minZ;maxZ;NaN];
    end

    minX = min(xTick);
    maxX = max(xTick);
    
    for zT=1:length(zTick)
        XV = [XV;minX;maxX;NaN];
        ZV = [ZV;zTick(zT);zTick(zT);NaN];
    end

    L = length(xTick)*3+length(zTick)*3;    
    YV = [YV;ones(L,1)*axesOrigin(2)];
    clear L
    
    kmlStrXZ = ge_folder('xz-plane (ge_axes)',...
                ge_plot3(XV,YV,ZV,...
                   'altitudeMode',altitudeMode,...
                      'lineColor',xzLineColor,...
                      'lineWidth',lineWidth,...
                      'name','grid line')); 
end

if exist('yTick','var')&&~isempty(findstr('y',axesType))&&...
   exist('zTick','var')&&~isempty(findstr('z',axesType))
    
   %%% Draw yz-plane only

    XV = [];
    YV = [];
    ZV = [];    

    %   altitudeMode = 'relativeToGround';
    
    minZ = min(zTick);
    maxZ = max(zTick);
    
    for yT=1:length(yTick)
        YV = [YV;yTick(yT);yTick(yT);NaN];
        ZV = [ZV;minZ;maxZ;NaN];
    end

    minY = min(yTick);
    maxY = max(yTick);
    
    for zT=1:length(zTick)
        YV = [YV;minY;maxY;NaN];
        ZV = [ZV;zTick(zT);zTick(zT);NaN];
    end

    L = length(zTick)*3+length(yTick)*3;    
    XV = [XV;ones(L,1)*axesOrigin(1)];
    clear L

    kmlStrYZ = ge_folder('yz-plane (ge_axes)',...
                ge_plot3(XV,YV,ZV,...
                   'altitudeMode',altitudeMode,...
                      'lineColor',yzLineColor,...
                      'lineWidth',lineWidth,...
                           'name','grid line')); 
    
    
end  




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% start drawing radial planes as specified %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if exist('hTick','var')&&~isempty(findstr('h',axesType))
   
   %%% Draw heading-plane only:    
    XV = [];
    YV = [];
    ZV = [];    
        
    for hT=1:length(hTick)
        XV = [XV;axesOrigin(1);axesOrigin(1)+hAxisLength*sin(deg2rad(hTick(hT)));NaN];
        YV = [YV;axesOrigin(2);axesOrigin(2)+hAxisLength*cos(deg2rad(hTick(hT)));NaN];
    end


    if isequal('altitudeMode','clampToGround')
        L = length(xTick)*3;    
        ZV = [ZV;ones(L,1)];
        clear L
    else
        L = length(hTick)*3;
        ZV = [ZV;ones(L,1)*axesOrigin(3)];
        clear L
    end
    
    kmlStrH = ge_folder('heading-plane (ge_axes)',...
                ge_plot3(XV,YV,ZV,...
                   'altitudeMode',altitudeMode,...
                      'lineColor',hLineColor,...
                      'lineWidth',lineWidth,...
                      'region', region, ...
                           'name','grid line'));
end

kmlStr = [kmlStrXY,kmlStrXZ,kmlStrYZ,kmlStrH];

if msgToScreen
    disp(['Running: ',mfilename,'...Done'])
end
    
         
%                       'id',id,...
%                    'idTag',idTag,...
%                     'name',name,...
%              'description',description,...
%                'timeStamp',timeStamp,...
%            'timeSpanStart',timeSpanStart,...
%             'timeSpanStop',timeSpanStop,...
%               'visibility',visibility,...
%                'lineColor',lineColor,...
%                'lineWidth',lineWidth,...

%                  'extrude',extrude,...
%               'tessellate',tessellate,...
%              'forceAsLine',forceAsLine);