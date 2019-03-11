function tag_str = ge_quiver3(XM,YM,ZM,UM,VM,WM,varargin)
% Reference page in help browser: 
%
% <a href="matlab:web(fullfile(ge_root,'html','ge_quiver3.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%

AuthorizedOptions = authoptions( mfilename );



    altitudeMode = 'absolute';
      arrowScale = 1;
    modelLinkStr = '[No model link specified]';
            name = 'ge_quiver3';
       timeStamp = ' ';
   timeSpanStart = ' ';
    timeSpanStop = ' ';
    snippet      = ' ';
    description = '';
         region = ' ';
fixedArrowLength = 0; 
     msgToScreen = false;

parsepairs %script that parses Parameter/Value pairs.

if msgToScreen
    disp(['Running: ',mfilename,'...'])
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

if ~ismember(fixedArrowLength,[0,1])
    error(['Function ',39,mfilename,39,': variable ',39,'fixedArrowLength',39,' may only be 0 or 1.'])
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

if snippet == ' '
    snippet_chars = '';
else
    snippet_chars = [ '<Snippet>' snippet '</Snippet>',10 ];    
end

description_chars = [ '<description>',10,'<![CDATA[' description ']]>',10,'</description>',10 ];

tag_str = ['<Placemark>' 10,...
                snippet_chars,...
                description_chars,...
                timeStamp_chars,...
                timeSpan_chars,...
                region_chars,...
                '<name>',name,'</name>' 10,...
                '<MultiGeometry>' 10];

xv = XM(:);
yv = YM(:);
zv = ZM(:);

uv = UM(:);
vv = VM(:);
wv = WM(:);

av = sqrt(uv.^2+vv.^2+wv.^2);

clear XM YM ZM UM VM WM

heading = zeros(size(xv));
tilt = zeros(size(xv));
roll = zeros(size(xv));


for k=1:length(xv)

    heading(k) = rad2deg(calc_dir(uv(k),vv(k)));
%    tilt(k) = rad2deg(calc_dir(wv(k),sqrt(uv(k).^2 + vv(k).^2)));
    tilt(k) = rad2deg(calc_dir(sqrt(uv(k).^2 + vv(k).^2),wv(k)))-90;
%     if tilt(k)<-90||tilt(k)>90
%          error(['Google Earth can do tilts from -90 (straight up) to 90 (straight down). ',10,...
%                  'Current value is ' num2str(tilt(k)),'.'])
%     end
    tag_str = [tag_str,...
                '<Model>', 10,...
                '<altitudeMode>' altitudeMode '</altitudeMode>', 10,...
                '<Location>', 10,...
                '   <longitude>' num2str(xv(k))  '</longitude>', 10,...
                '   <latitude>' num2str(yv(k)) '</latitude>', 10,...
                '   <altitude>' num2str(zv(k)) '</altitude>', 10,...
                '</Location>', 10,...
                '<Orientation>', 10,...
                '   <heading>' num2str(heading(k))  '</heading>', 10,...
                '   <tilt>' num2str(tilt(k)) '</tilt>', 10,...
                '   <roll>' num2str(roll(k)) '</roll>', 10,...
                '</Orientation>', 10,...
                '<Scale>', 10'];
    if fixedArrowLength==1
        tag_str = [tag_str,...
                '   <x>',num2str(arrowScale),'</x>', 10,...
                '   <y>',num2str(arrowScale),'</y>', 10,...
                '   <z>',num2str(arrowScale),'</z>', 10];
    else
        tag_str = [tag_str,...
                '   <x>',num2str(arrowScale*av(k)),'</x>', 10,...
                '   <y>',num2str(arrowScale*av(k)),'</y>', 10,...
                '   <z>',num2str(arrowScale*av(k)),'</z>', 10];
    end
    
    tag_str = [tag_str,...
                '</Scale>', 10,...
                '<Link>', 10,...
                '   <href>' modelLinkStr '</href>', 10,...
                '</Link>', 10,...
                '</Model>', 10, 10, 10 ];
                
end
                
tag_str = [tag_str, 10,...
           '</MultiGeometry>' 10,...
           '</Placemark>' 10];

if msgToScreen
    disp(['Running: ',mfilename,'...Done'])
end
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = calc_dir(U,V)

dy = V;
dx = U;

if (dy==0) && (dx==0)
    a=0;
%     error(['Unable to determine the direction of' 10 'a zero-length vector. Function: ' 39 mfilename 39 '.'])
elseif (dy==0)&&(dx>0)
    a = 0.5*pi;
elseif (dy==0)&&(dx<0)
    a = 1.5*pi;
elseif (dy>0)&&(dx==0)
    a = 0;
elseif (dy<0)&&(dx==0)
    a = pi;    
elseif (dy>0)&&(dx>0)
    a = mod(atan(dx/dy),2*pi);%#
elseif (dy>0)&&(dx<0)
    a = mod(atan(dx/dy),2*pi);%#
elseif (dy<0)&&(dx>0)
    a = mod(pi+atan(dx/dy),2*pi);%#
elseif (dy<0)&&(dx<0)
    a = mod(pi+atan(dx/dy),2*pi);%#
else
    a=NaN;%#
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = rad2deg(r)

d = (r/(2*pi))*360;


