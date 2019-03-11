function output = ge_box(x_min,x_max,y_min,y_max,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_box.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%

AuthorizedOptions = authoptions( mfilename );


            id = 'box';
         idTag = 'id';
          name = 'ge_box';
   description = '';
     timeStamp = ' ';
 timeSpanStart = ' ';
  timeSpanStop = ' ';
    visibility = 1;
     lineColor = 'ffffffff';
   msgToScreen = 0;
     polyColor = 'ffffffff';
     lineWidth = 1.0;
       snippet = ' ';
      altitude = 1.0;
       extrude = 1;
    tessellate = 0;
  altitudeMode = 'clampToGround';
      region = ' ';

parsepairs %script that parses Parameter/Value pairs.

if msgToScreen
   disp(['Running ' mfilename '...']) 
end

if( isempty( y_min ) || isempty( y_max ) || isempty(x_min) || isempty(x_max) )
    error('empty coordinates passed to ge_box(...).');
end

if region == ' '
	region_chars = '';
else
	region_chars = [ region, 10 ];
end

if ~(isequal(altitudeMode,'clampToGround')||...
   isequal(altitudeMode,'relativeToGround')||...
   isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])
    
end   
    
id_chars = [ idTag '="' id '"' ];
poly_id_chars = [ idTag '="poly_' id '"' ];
name_chars = [ '<name>',10,name,10,'</name>',10 ];
description_chars = [ '<description>',10,'<![CDATA[' description ']]>',10,'</description>',10 ];
visibility_chars = [ '<visibility>',10,int2str(visibility),10,'</visibility>',10];
lineColor_chars = [ '<color>',10,lineColor([1,2,7,8,5,6,3,4]),10,'</color>',10];
polyColor_chars = [ '<color>',10,polyColor,10,'</color>',10];
lineWidth_chars= [ '<width>',10,num2str(lineWidth, '%.2f'),10,'</width>',10 ];
altitudeMode_chars = [ '<altitudeMode>',10,altitudeMode,10,'</altitudeMode>',10 ];
if snippet == ' '
    snippet_chars = '';
else
    snippet_chars = [ '<Snippet>' snippet '</Snippet>',10 ];    
end
extrude_chars = [ '<extrude>' int2str(extrude) '</extrude>',10 ];
tessellate_chars = [ '<tessellate>' int2str(tessellate) '</tessellate>',10 ];

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

header = ['<Placemark ',id_chars,'>',10,...
            name_chars,...
            timeStamp_chars,...
            timeSpan_chars,...
            visibility_chars, ...
            snippet_chars, ...
            description_chars,10,...
            region_chars, ...
            '<Style>',10,...
                '<LineStyle>',10,...
                    lineColor_chars, ...
                    lineWidth_chars, ...
                '</LineStyle>',10,...
                '<PolyStyle>',10,...
                    polyColor_chars, ...
                '</PolyStyle>',10,...
            '</Style>',10,...
          '<Polygon ',poly_id_chars,'>',10,...
            extrude_chars,...
             altitudeMode_chars,...
            '<outerBoundaryIs>',10,...
              '<LinearRing>',10,...
              extrude_chars, ...
              tessellate_chars, ...
              altitudeMode_chars, ...
                '<coordinates>',10];
    
coordinates = [ sprintf('%.6f,%.6f,%.6f ', x_min, y_min, altitude),10,...
              sprintf('%.6f,%.6f,%.6f ', x_max, y_min, altitude),10,...
              sprintf('%.6f,%.6f,%.6f ', x_max, y_max, altitude),10,...
              sprintf('%.6f,%.6f,%.6f ', x_min, y_max, altitude),10,...
              sprintf('%.6f,%.6f,%.6f ', x_min, y_min, altitude),10 ];

footer = ['</coordinates>',10,...
      '</LinearRing>',10,...
    '</outerBoundaryIs>',10,...
  '</Polygon>',10,...
'</Placemark>',10];

output = [ header, coordinates, footer ];

if msgToScreen
   disp(['Running ' mfilename '...Done']) 
end