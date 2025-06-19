function [output] = ge_point_new(X,Y,Z,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_point.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


AuthorizedOptions = authoptions( mfilename );

    altitudeMode = 'relativeToGround';
   dataFormatStr = '%g';
tableBorderWidth = 1;
     description = ' ';
         extrude = 0;
       iconColor = 'FFFFFFFF';
       iconScale = 1.0;
         iconURL = ' ';
              id = 'point';
           idTag = 'id';
     msgToScreen = false;
     snippet     = ' ';
%        lineColor = 'ffffffff';
%        lineWidth = 1.0; 
            name = '';
       timeStamp = ' ';
   timeSpanStart = ' ';
    timeSpanStop = ' ';
      visibility = 1;
     %iconLabels = ...
   pointDataCell = {};
          region = ' ';


parsepairs %script that parses Parameter/Value pairs.

if msgToScreen
    disp(['Running: ',mfilename,'...'])
end

htmlTableChars = '';


if numel(X)==1
    
    timeEntryChars = '';
    if ~strcmp(timeSpanStart,' ')
        timeEntryChars = [timeEntryChars,'<TR><TD>tStart</TD><TD>',timeSpanStart,'</TD></TR>'];
    end   
    if ~strcmp(timeSpanStop,' ')
        timeEntryChars = [timeEntryChars,'<TR><TD>tStop</TD><TD>',timeSpanStop,'</TD></TR>'];
    end

    
    if strcmp(description,' ')


            description = ['<TABLE border=',34,int2str(tableBorderWidth),34,'><TR><TD><B>Variable</B></TD><TD><B>Value</B></TD></TR>',...
                                 '<TR><TD>longitude [decimal degrees]</TD><TD>',num2str(X,dataFormatStr),'</TD></TR>',...
                                 '<TR><TD>latitude [decimal degrees]</TD><TD>',num2str(Y,dataFormatStr),'</TD></TR>',...                         
                                 '<TR><TD>elevation [m]</TD><TD>',num2str(Z,dataFormatStr),'</TD></TR>',...
                                 timeEntryChars,htmlTableChars];
        if ~isempty(pointDataCell)

            for r=1:size(pointDataCell,1)
                htmlTableChars = [htmlTableChars,'<TR><TD>',pointDataCell{r,1},'</TD><TD>',pointDataCell{r,2},'</TD></TR>'];
            end
            description = [description,htmlTableChars];
        end
        description = [description,'</TABLE>'];
    end
    
else
    % multiple points
%     passArgsOn = varargin;
    kmlStr = '';
    for k=1:numel(X)
        
        if strcmp(timeSpanStart,' ')
            timeSpanStart_1x1 = timeSpanStart;
        elseif numel(timeSpanStart)==1
            timeSpanStart_1x1 = timeSpanStart{1};
        else
            timeSpanStart_1x1 = timeSpanStart{k};
        end
        
        if strcmp(timeSpanStop,' ')
            timeSpanStop_1x1 = timeSpanStop;
        elseif numel(timeSpanStop)==1
            timeSpanStop_1x1 = timeSpanStop{1};
        else
            timeSpanStop_1x1 = timeSpanStop{k};
        end
        
        if isequal(description,' ')
            description_1x1 = description;
        elseif numel(description)==1
            description_1x1 = description{1};
        else
            description_1x1 = description{k};
        end
        
        if isempty(pointDataCell)
            pointDataCell_1x1 = pointDataCell;
        elseif numel(pointDataCell)==1
            pointDataCell_1x1 = pointDataCell{1};
        else
            pointDataCell_1x1 = pointDataCell{k};
        end
        
        if numel(Z)==1
            Z_1x1 = Z;
        else
            Z_1x1 = Z(k);
        end

        kmlStr = [kmlStr,ge_point(X(k),Y(k),Z_1x1,...
                'timeSpanStart',timeSpanStart_1x1,...
                'timeSpanStop',timeSpanStop_1x1,...
                'description',description_1x1,...
                'pointDataCell',pointDataCell_1x1,...
                'altitudeMode',altitudeMode,...
                'dataFormatStr',dataFormatStr,...
                'tableBorderWidth',tableBorderWidth,...
                'extrude',extrude,...
                'iconColor',iconColor,...
                'iconScale',iconScale,...
                'iconURL',iconURL,...
                'msgToScreen',msgToScreen,...
                'snippet',snippet,...
                'name',name,...
                'visibility',visibility,...
                'region',region)];
    end
    output = kmlStr;
    return
end


if( isempty( X ) || isempty( Y ) || isempty(Z) )
    error('empty coordinates passed to ge_point(...).');
else
    if ~isequal(size(X(:)),size(Y(:))) 
        error(['Coordinate vectors of different length passed' 10 'to function: ' 39 mfilename 39 '.'])
    else
        coords(:,1) = X(:);
        coords(:,2) = Y(:);
        coords(:,3) = Z(:);
    end
end

if region == ' '
	region_chars = '';
else
	region_chars = [ region 10 ];
end

if ~(isequal(altitudeMode,'clampToGround')||...
   isequal(altitudeMode,'relativeToGround')||...
   isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])
    
end   

id_chars = [ idTag '="' id '"' ];
poly_id_chars = [ idTag '="point_' id '"' ];
name_chars = [ '<name>',10,name,10,'</name>',10 ];
if snippet == ' '
    snippet_chars = '';
else
    snippet_chars = [ '<Snippet>' snippet '</Snippet>',10 ];    
end
description_chars = [ '<description>',10,'<![CDATA[' description ']]>',10,'</description>',10 ];
visibility_chars = [ '<visibility>',10,int2str(visibility),10,'</visibility>',10];
% lineColor_chars = [ '<color>',10, lineColor ,10,'</color>',10 ];
% lineWidth_chars= [ '<width>',10, num2str(lineWidth, '%.2f') ,10,'</width>',10 ];
extrude_chars = [ '<extrude>' int2str(extrude) '</extrude>',10 ];

if iconURL == ' '
    icon_chars = '';
else
    icon_chars = [ ...
    '<IconStyle>',10,...
    '<color>', iconColor([1,2,7,8,5,6,3,4]), '</color>',10,...
    '<scale>' num2str(iconScale) '</scale>',10,...
    '<Icon>',10,...
    '<href>' iconURL '</href>',10,...
    '</Icon>',10, ...
    '</IconStyle>' ]; 

end

if timeStamp == ' '
    timeStamp_chars = '';
else
    timeStamp_chars = [ '<TimeStamp><when>' timeStamp '</when></TimeStamp>',10 ];
end

if timeSpanStart == ' '
    timeSpan_chars = '';
else
    if timeSpanStop == ' ' 
        timeSpan_chars = [ '<TimeSpan><begin>' timeSpanStart '</begin></TimeSpan>',10 ];
    else
        timeSpan_chars = [ '<TimeSpan><begin>' timeSpanStart '</begin><end>' timeSpanStop '</end></TimeSpan>',10 ];    
    end
        
end

header=['<Placemark ',id_chars,'>',10,...
    name_chars,10,...
    timeStamp_chars,...
    timeSpan_chars,...
    visibility_chars,10,...
    snippet_chars,...
    description_chars,10,...
    icon_chars, ...
    region_chars,...
    '<Style>',10,...
        icon_chars, ...
    10,'</Style>',10,...
  '<Point ',poly_id_chars,'>',10,...
    '<altitudeMode>',altitudeMode,'</altitudeMode>',10,...
    '<tessellate>',10,'1',10,'</tessellate>',10,...
    extrude_chars,10,...
    '<coordinates>',10];

footer = ['</coordinates>',10,...
    10,'</Point>',10,...
    10,'</Placemark>',10];  

%path plot or not
len = length(coords(:,1,1));
output = '';
if length( coords(:,1) ) > 1

    for x = 1:len
        if ~isnan(coords(x,1))
            coordinates = conv_coord(coords(x,:));
            output = [ output, header, coordinates, footer ];
        end
    end
   
else
    if ~isnan(coords)
        coordinates = conv_coord(coords);
        output = [ header, coordinates, footer ]; 
    end
end


if msgToScreen
    disp(['Running: ',mfilename,'...Done'])
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS START HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function s = conv_coord(M)
%% conv_coord(M)
% helper function to conver decimal degree coordinates into character array
s=[];

for r=1:size(M,1)
    for c=1:size(M,2)
        s = [s,sprintf('%.6f',M(r,c))];
        s = trim_trail_zero(s);
        if c==size(M,2)
            s=[s,10];
        else
            s=[s,','];          
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s_out = trim_trail_zero(s_in)
%   helper function meant to trim trailing character zeros from a character
%   array.

dig = 1;
L = length(s_in);
last_char = s_in(L);

cont = true;

while (strcmp(last_char,'0') | strcmp(last_char,'.')) & cont==1
    if strcmp((last_char),'.')
        cont = 0;
    end
    s_in = s_in(1:L-dig);
    last_char = s_in(length(s_in));
    dig = dig+1;
end

s_out = s_in;




