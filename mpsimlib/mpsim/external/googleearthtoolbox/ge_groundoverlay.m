function output = ge_groundoverlay(y_max,x_max,y_min,x_min,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_groundoverlay.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


AuthorizedOptions = authoptions( mfilename );
 

         id = 'groundoverlay';
      idTag = 'id';
       name = 'ge_groundoverlay';
description = '';
    timeStamp = ' ';
timeSpanStart = ' ';
 timeSpanStop = ' ';
 rotation = 0.0;
    color = 'ffffffff';
 visibility = 1;
     altitude = 1.0;
      extrude = 0;
 altitudeMode = 'clampToGround';
  tmpFileStr = mfilename('fullpath');
  imgURL = [tmpFileStr(1:max(findstr(tmpFileStr,filesep))),'data',filesep,'image_file_unavailable.bmp'];
  clear tmpFileStr
  viewBoundScale = 1.0;
  snippet = ' ';
  msgToScreen = false;
    polyAlpha = 'ff';
    region = ' ';
    
parsepairs %script that parses Parameter/Value pairs.

if msgToScreen
    disp(['Running: ',mfilename,'...'])
end

if( isempty( y_max ) || isempty( y_min ) || isempty( x_max ) || isempty( x_min ) )
    error('empty coordinates passed to ge_groundoverlay(...).');
end

finalColor = [polyAlpha, color(3:end)];

if region == ' '
	region_chars = '';
else
	region_chars = [ region, 10 ];
end

id_chars = [ idTag '="', id '"' ];
name_chars = [ '<name>',10, name ,10,'</name>',10 ];
description_chars = [ '<description>',10,'<![CDATA[' description ']]>',10,'</description>',10 ];
visibility_chars = [ '<visibility>',10, int2str(visibility) ,10,'</visibility>',10 ];
%color_chars = [ '<color>',10, color,10, '</color>',10 ];
altitudeMode_chars = ['<altitudeMode>',altitudeMode,'</altitudeMode>'];
finalColor_chars = [ '<color>',10,finalColor,10,'</color>',10,];
if snippet == ' '
    snippet_chars = '';
else
    snippet_chars = [ '<Snippet>' snippet '</Snippet>',10 ];    
end
imgURL_chars =  ['<href>',10, imgURL,10, '</href>',10];
viewBoundScale_chars = ['<viewBoundScale>',10, num2str(viewBoundScale),10, '</viewBoundScale>',10];
extrude_chars = [ '<extrude>' int2str(extrude) '</extrude>',10 ];

if ~(isequal(altitudeMode,'clampToGround')||...
   isequal(altitudeMode,'relativeToGround')||...
   isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])
    
end   

if altitude > 1.0
    altitude_chars = sprintf('<altitude>%.2f</altitude>',altitude);
    lat_chars_start = '<LatLonAltBox>';
    lat_chars_stop = '</LatLonAltBox>';
    lat_chars_middle = [ sprintf('<minAltitude>%.2f</minAltitude>',altitude),...
                        sprintf('<maxAltitude>%.2f</maxAltitude>',altitude)];   
else
    altitudeMode_chars = '';
    altitude_chars = '';
    lat_chars_start = '<LatLonBox>';
    lat_chars_stop = '</LatLonBox>';
    lat_chars_middle = [sprintf('<rotation>%.16f</rotation>',rotation)];
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

%topology overlay
header=['<GroundOverlay ',id_chars,'>',10,...
        name_chars,...
        timeStamp_chars,...
        timeSpan_chars,...
        snippet_chars,...
        description_chars,...
        region_chars, ...
        finalColor_chars,...
        visibility_chars,...
        extrude_chars,...
        altitude_chars,...
        altitudeMode_chars,...
        '<Icon>',10,...
            imgURL_chars,...
            viewBoundScale_chars,...
        '</Icon>',10,...
        lat_chars_start,10];

		coords= [ sprintf('<north>%.6f</north>', y_max),...
                sprintf('<south>%.6f</south>', y_min),...
                sprintf('<east>%.6f</east>', x_max),...
                sprintf('<west>%.6f</west>', x_min),...
                sprintf('%s',lat_chars_middle)];
        
footer = [10,lat_chars_stop,10,...
        '</GroundOverlay>',10];
    
output = [header, coords, footer];


 
if msgToScreen
    disp(['Running: ',mfilename,'...Done'])
end
