function output = ge_plot(X,Y,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_plot.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


AuthorizedOptions = authoptions( mfilename );


            id = 'plot';
         idTag = 'id';
     timeStamp = ' ';
 timeSpanStart = ' ';
  timeSpanStop = ' ';
          name = 'ge_plot';
      snippet  = ' ';
   description = '';
    visibility = 1;
     lineColor = 'ffffffff';
     lineWidth = 1.0;
   msgToScreen = false;
      altitude = 1;
  altitudeMode = 'clampToGround';
       extrude = 0;
    tessellate = 1;
   forceAsLine = true;   
        region = ' ';
  
parsepairs %script that parses Parameter/Value pairs.

if msgToScreen
    disp(['Running ', mfilename, '...'])
end

if( isempty( X ) || isempty( Y ) )
    error('empty coordinates passed to ge_plot(...).');
else
    if ~isequal(size(X(:)),size(Y(:))) 
        error(['Coordinate vectors of different length passed' 10 'to function: ' 39 mfilename 39 '.'])
    else
%         coords(:,1) = X;
%         coords(:,2) = Y;
        X=X(:);
        Y=Y(:);
%         while any(isnan(X(end,:)))|any(isnan(Y(end,:)))
%             X = X(1:end-1,:);
%             Y = Y(1:end-1,:);            
%         end

        %bug reported by Olaf Vellinga... mapybe works for more cases?
        %Better fix later...
        try
            Z = X-X+~isnan(X)*altitude; 
        catch
            Z = altitude;
        end
    end
end


id_chars = [ idTag '="' id '"' ];
poly_id_chars = [ idTag '="poly_' id '"' ];
name_chars = [ '<name>',10, name,10, '</name>',10 ];
description_chars = [ '<description>',10,'<![CDATA[' description ']]>',10,'</description>',10 ];
visibility_chars = [ '<visibility>',10, int2str(visibility) ,10,'</visibility>',10 ];
LineColor_chars = [ '<color>',10, lineColor([1,2,7,8,5,6,3,4]),10, '</color>',10 ];
LineWidth_chars= [ '<width>',10, num2str(lineWidth, '%.2f'),10, '</width>',10 ];
altitudeMode_chars = ['<altitudeMode>',altitudeMode,'</altitudeMode>'];
extrude_chars = [ '<extrude>' int2str(extrude) '</extrude>',10 ];
tessellate_chars = [ '<tessellate>' int2str(tessellate) '</tessellate>',10 ];

if region == ' '
	region_chars = '';
else
	region_chars = [ region, 10 ];
end

if snippet == ' '
    snippet_chars = '';
else
    snippet_chars = [ '<Snippet>' snippet '</Snippet>',10 ];    
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
    region_chars,...
    '<Style>',10,...
        '<LineStyle>',10,...
            LineColor_chars,10,...
            LineWidth_chars,10,...
        '</LineStyle>',10,...
    '</Style>',10,...
  '<LineString ',poly_id_chars,'>',10,...
    extrude_chars,10,...
tessellate_chars,10,...
altitudeMode_chars,10,...
    '<coordinates>',10];

%coordinates = conv_coord(coords);


footer = ['</coordinates>',10,...
    10,'</LineString>',10,...
    10,'</Placemark>',10];  

% output = [ header, coordinates, footer ];


X=[NaN;X;NaN];
Y=[NaN;Y;NaN];
Z=[NaN;Z;NaN];

nanIX = isnan(X.*Y);
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
                 Y(LineStringEndIx(x))~=Y(LineStringStartIx(x)))
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOCAL FUNCTIONS START HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
