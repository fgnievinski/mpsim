function output = ge_plot3(X,Y,Z,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_plot3.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


AuthorizedOptions = authoptions( mfilename );


         id = 'plot3';
      idTag = 'id';
       name = 'ge_plot3';
description = '';
    timeStamp = ' ';
timeSpanStart = ' ';
 timeSpanStop = ' ';
 visibility = 1;
  lineColor = 'ffffffff';
  polyColor = '00ffffff';
  lineWidth = 1.0;
    snippet = ' ';
%    altitude = 1.0;
     extrude = 0;
     tessellate = 0;
 altitudeMode = 'relativeToGround';
 msgToScreen = false;
 forceAsLine = true; % avoid closing of LinearRings by OpenGL
      region = ' ';
      
parsepairs %script that parses Parameter/Value pairs.


if msgToScreen
    disp(['Running: ' mfilename '...'])
end

if( isempty( X ) || isempty( Y ) || isempty(Z) )
    error('empty coordinates passed to ge_plot3(...).');
else
    if ~isequal(size(X(:)),size(Y(:))) 
        error(['Coordinate vectors of different length passed' 10 'to function: ' 39 mfilename 39 '.'])
%     else
%         if forceAsLine
%             X = X(:);
%             Y = Y(:);
%             Z = Z(:);
%             coords(:,1) = [X;flipud(X);X(1)];
%             coords(:,2) = [Y;flipud(Y);Y(1)];
%             coords(:,3) = [Z;flipud(Z);Z(1)];
%         else
%             coords(:,1) = X;
%             coords(:,2) = Y;
%             coords(:,3) = Z; 
%         end
            
    end
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
name_chars = [ '<name>',10, name,10, '</name>',10 ];
description_chars = [ '<description>',10,'<![CDATA[' description ']]>',10,'</description>',10 ];
visibility_chars = [ '<visibility>',10, int2str(visibility),10, '</visibility>',10 ];
lineColor_chars = [ '<color>',10, lineColor([1,2,7,8,5,6,3,4]),10, '</color>',10 ];
polyColor_chars = [ '<color>',10, polyColor([1,2,7,8,5,6,3,4]),10, '</color>',10 ];
lineWidth_chars= [ '<width>',10, num2str(lineWidth, '%.2f') ,10,'</width>',10 ];
altitudeMode_chars = [ '<altitudeMode>',10, altitudeMode,10, '</altitudeMode>',10 ];
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

header = ['<Placemark ',id_chars,'>',10, ...
            name_chars, ...
            timeStamp_chars,...
            timeSpan_chars,...
            visibility_chars, ...
            snippet_chars, ...
            description_chars, ...
            region_chars, ...
            '<Style>',10, ...
                '<LineStyle>',10, ...
                    lineColor_chars, ...
                    lineWidth_chars, ...
                '</LineStyle>',10, ...
                '<PolyStyle>',10, ...
                    polyColor_chars, ...
                '</PolyStyle>',10, ...
            '</Style>',10, ...
          '<Polygon ',poly_id_chars,'>',10, ...
            extrude_chars, ...
            altitudeMode_chars, ...
            '<outerBoundaryIs>',10, ...
              extrude_chars, ...
              '<LinearRing>',10, ...
              extrude_chars, ...
              tessellate_chars, ...
              altitudeMode_chars, ...
                '<coordinates>',10];

% coordinates = conv_coord(coords);


footer = ['</coordinates>',10, ...
      '</LinearRing>',10, ...
    '</outerBoundaryIs>',10, ...
  '</Polygon>',10, ...
'</Placemark>',10];


% output = [ header, coordinates, footer ];



X=[NaN;X(:);NaN];
Y=[NaN;Y(:);NaN];
Z=[NaN;Z(:);NaN];

nanIX = isnan(X.*Y.*Z);
LineStringStartIx = 1+find(nanIX(1:end-1)&~nanIX(2:end));
LineStringEndIx = find(~nanIX(1:end-1)&nanIX(2:end));
%nPolygons = length(LineStringStartIx);
output = '';
for x = 1:length(LineStringStartIx)
    %generate Coords        
    coordinates = [];
    if (LineStringEndIx(x)-LineStringStartIx(x))>=1
        if forceAsLine&&...
                (X(LineStringEndIx(x))~=X(LineStringStartIx(x))||...
                 Y(LineStringEndIx(x))~=Y(LineStringStartIx(x))||...
                 Z(LineStringEndIx(x))~=Z(LineStringStartIx(x)))
                 
            %for-loop through all points and backtrace all points...
            for ii = [LineStringStartIx(x):LineStringEndIx(x),LineStringEndIx(x):-1:LineStringStartIx(x)]
                
            coordinates = [ coordinates, ...
                            sprintf('%.6f,%.6f,%.6f ', X(ii), Y(ii), Z(ii)),10];
            end %for
        else
            %for-loop through all points...
            for ii = [LineStringStartIx(x):LineStringEndIx(x)]
            coordinates = [ coordinates, ...
                            sprintf('%.6f,%.6f,%.6f ', X(ii), Y(ii), Z(ii)),10];
            end %for
        end   % if
        output = [ output, header, coordinates, footer];    
    end %if
end

if msgToScreen
    disp(['Running ', mfilename, '...Done'])
end

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% LOCAL FUNCTIONS START HERE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% function s = conv_coord(M)
% %% conv_coord(M)
% % helper function to conver decimal degree coordinates into character array
% s=[];
% 
% for r=1:size(M,1)
%     for c=1:size(M,2)
%         s = [s,sprintf('%.6f',M(r,c))];
%         s = trim_trail_zero(s);
%         if c==size(M,2)
%             s=[s,10];
%         else
%             s=[s,','];          
%         end
%     end
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% function s_out = trim_trail_zero(s_in)
% %   helper function meant to trim trailing character zeros from a character
% %   array.
% 
% dig = 1;
% L = length(s_in);
% last_char = s_in(L);
% 
% cont = true;
% 
% while (strcmp(last_char,'0') | strcmp(last_char,'.')) & cont==1
%     if strcmp((last_char),'.')
%         cont = 0;
%     end
%     s_in = s_in(1:L-dig);
%     last_char = s_in(length(s_in));
%     dig = dig+1;
% end
% 
% s_out = s_in;
% 



