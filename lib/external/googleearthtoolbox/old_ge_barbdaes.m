function old_ge_barbdaes(varargin)


AuthorizedOptions = authoptions( mfilename );


Default_barbColor = 'FFFFFF';
Default_barbAlpha = '80';
        barbColor = Default_barbColor;
        barbAlpha = Default_barbAlpha;
      msgToScreen = 0;
           daeDir = ['daes',filesep];
    
parsepairs %script that parses Parameter/value pairs.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% start of integrity checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(barbColor)==8
    barbColor = Default_barbColor;
    barbAlpha = Default_barbAlpha;    
    warning(['Windbarb transparency should be set separately using',10,...
              'the ',39,'barbAlpha',39,' parameter. Wind barb color and transparency',10,...
              'have been reset to their default values.',10])
end

if length(barbColor)~=6
    barbColor = Default_barbColor;
    warning(['Use a character array of length 6 to specify barb color',10,...
             'using hexidecimal notation for red, green, and blue intensities.',10,...
             'Wind barb color has been reset to its default value.',10])
end
barbColorRGB = num2str([hex2dec(barbColor(1:2)),...
                        hex2dec(barbColor(3:4)),...
                        hex2dec(barbColor(5:6))]/255,'% 5.3f% 5.3f% 5.3f');    


barbAlphaFrac = num2str(hex2dec(barbAlpha(1:2))/255,'% 5.3f');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% end of integrity checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if msgToScreen
    disp(['Generating wind barb Collada models...',10])
end
V=([0,2.5,7.5,12.5:5:105]+1e-8)*0.51;
for h=[1,2]
for k=1:length(V)-2
        
        
        if h==1
            hemiStr='North';
        elseif h==2
            hemiStr='South';
        end
        [xcoords, ycoords] = ge_windbarb_poly(0,0,0,-V(k),'barbScale',100,'hemisphere',hemiStr);
        
%         figure(1)
%         patch(mod(k-1,5)+xcoords(1:end-1),6-floor((k-1)/5)*2+ycoords(1:end-1),'k')
%         axis image
%         set(gca,'ydir','normal','ylim',[-0.5,7.5],'xlim',[-0.5,4.5])
%         axis off
%         print('arrows','-dbmp')
        

        Ix = find(~isnan(xcoords.*ycoords));
        xcoords = xcoords(Ix);
        ycoords = ycoords(Ix);
        
        if strcmp(hemiStr,'North')
            locStr = ['1 ',num2str(length(xcoords)-2),' 2 2 ',num2str(length(xcoords)-2),' 3'];
        elseif strcmp(hemiStr,'South')
            locStr = ['1 2 ',num2str(length(xcoords)-2),' ',num2str(length(xcoords)-2),' 2 3'];
        end
        
        if k==1
            L=0;
            locStr = '0 2 1 0 3 2';
        elseif k==2
            StartNode = 5;
            L = (length(xcoords)-5)/4;
        elseif k>2&&k<11
            if abs(round(k/2)-(k/2))<1e-8 %iseven
                StartNode = 4;
                L = (length(xcoords)-5)/4;
            else
                StartNode = 4;
                L = (length(xcoords)-5-1)/4;
            end
        elseif k>=11&&k<21
            StartNode = 4;
            if strcmp(hemiStr,'North')
                locStr = [locStr,' ',num2str(StartNode-1),...
                             ' ',num2str(StartNode+2-1),...
                             ' ',num2str(StartNode+1-1)];
            elseif strcmp(hemiStr,'South')                         
                locStr = [locStr,' ',num2str(StartNode+2-1),...
                             ' ',num2str(StartNode-1),...
                             ' ',num2str(StartNode+1-1)];
            else
            end
            StartNode = 7;
            L = (length(xcoords)-8)/4;
        end
        
        for r=1:L
            if strcmp(hemiStr,'North')
            locStr = [locStr,' ',num2str(StartNode-1),...
                             ' ',num2str(StartNode+2-1),...
                             ' ',num2str(StartNode+1-1),...
                             ' ',num2str(StartNode+2-1),...
                             ' ',num2str(StartNode-1),...
                             ' ',num2str(StartNode+3-1)];
            elseif strcmp(hemiStr,'South')
            locStr = [locStr,' ',num2str(StartNode+3-1),...
                             ' ',num2str(StartNode+0-1),...
                             ' ',num2str(StartNode+2-1),...
                             ' ',num2str(StartNode+2-1),...
                             ' ',num2str(StartNode+0-1),...
                             ' ',num2str(StartNode+1-1)];
            else
            end
            StartNode = StartNode + 4;
        end
            
        clear L StartNode
        
        M = rot90(fliplr([xcoords,ycoords,zeros(size(xcoords))]));
        
        XYZpointsArrayStr='';
        for m=1:numel(M)
            XYZpointsArrayStr = [XYZpointsArrayStr,' ',num2str(M(m),'%f')];
        end
        
        N = rot90(fliplr([zeros(size(Ix,1),2),ones(size(Ix,1),1)]));
        NormalsArrayStr='';
        for u=1:numel(N)
            NormalsArrayStr = [NormalsArrayStr,' ',num2str(N(u),'%d')];
        end
        
        filename = [daeDir,num2str(((h-1)*(length(V)-2))+k,'%03d'),lower(hemiStr(1)),'hemi',num2str(round(V(k)/0.051),'%04d'),num2str(round(V(k+1)/0.051),'%04d'),'kts.dae'];

if exist(daeDir,'dir')==0
    s = strrep(daeDir,'\','\\');
    UserFeedback = input(['Target directory: ',39,s,39,' does not exist.',10,'Do you want to create it? [Y]/N:  '],'s');
    clear s
    if strcmp(upper(UserFeedback),'Y')||strcmp(UserFeedback,'')
        mkdir(daeDir)
        disp('Creating target directory...')
        pause(1.0)
        disp(['Creating target directory...Done',10])
        pause(0.5)
    else
        disp('Aborting...')
        pause(1.0)
        disp(['Aborting...Done',10])
        pause(0.5)
        return
    end
end    
    
fid=fopen(filename,'wt');

xmlStr =['<?xml version=',34,'1.0',34,' encoding=',34,'utf-8',34,'?>',10,...
'<COLLADA version=',34,'1.4.0',34,' xmlns=',34,'http://www.collada.org/2005/11/COLLADASchema',34,'>',10,...
'<asset>',10,...
	'	<contributor>',10,...
    '		<author>MATLAB Collada exporter, Illusoft Collada 1.4.0 plugin for Blender - http://colladablender.illusoft.com</author>',10,...
	'		<authoring_tool>MATLAB Collada exporter, Blender v:242 - Illusoft Collada Exporter v:0.2.65</authoring_tool>',10,...
	'		<comments></comments>',10,...
	'		<copyright></copyright>',10,...
	'		<source_data>untitled.blend</source_data>',10,...
	'	</contributor>',10,...
	'	<created>',datestr(now),'</created>',10,...
	'	<modified>',datestr(now),'</modified>',10,...
	'	<unit meter=',34,'0.01',34,' name=',34,'centimeter',34,'/>',10,...
	'	<up_axis>Z_UP</up_axis>',10,...
	'</asset>',10,...
	'<library_effects>',10,...
	'	<effect id=',34,'Material_001-fx',34,' name=',34,'Material_001-fx',34,'>',10,...
	'		<profile_COMMON>',10,...
	'			<technique sid=',34,'',34,'>',10,...
	'				<phong>',10,...
	'					<emission>',10,...
	'						<color>0.0 0.0 0.0 1.0</color>',10,...
	'					</emission>',10,...
	'					<ambient>',10,...
	'						<color>0.48814 0.02131 0.02131 1.0</color>',10,...
	'					</ambient>',10,...
	'					<diffuse>',10,...
	'						<color>',barbColorRGB,' 1.0</color>',10,...
	'					</diffuse>',10,...
	'					<specular>',10,...
	'						<color>0.5 0.5 0.5 1.0</color>',10,...
	'					</specular>',10,...
	'					<shininess>',10,...
	'						<float>12.5</float>',10,...
	'					</shininess>',10,...
	'					<reflective>',10,...
	'						<color>1.0 1.0 1.0 1.0</color>',10,...
	'					</reflective>',10,...
	'					<reflectivity>',10,...
	'						<float>0.8</float>',10,...
	'					</reflectivity>',10,...
	'					<transparent>',10,...
	'						<color>1 1 1 1</color>',10,...
	'					</transparent>',10,...
	'					<transparency>',10,...
	'						<float>',barbAlphaFrac,'</float>',10,...
	'					</transparency>',10,...
	'				</phong>',10,...
	'			</technique>',10,...
	'		</profile_COMMON>',10,...
	'	</effect>',10,...
	'</library_effects>',10,...
    '<library_geometries>',10,...
    '<geometry id=',34,'Plane-Geometry',34,' name=',34,'Plane-Geometry',34,'>',10,...
    '   <mesh>',10,...
    '       <source id=',34,'Plane-Geometry-Position',34,'>',10,...
    '           <float_array count=',34,num2str(numel(M)),34,' id=',34,'Plane-Geometry-Position-array',34,'>',XYZpointsArrayStr,' </float_array>',10,...
    '           <technique_common>',10,...
    '               <accessor count=',34,num2str(numel(M)/3),34,' source=',34,'#Plane-Geometry-Position-array',34,' stride=',34,'3',34,'>',10,...
    '                  <param name=',34,'X',34,' type=',34,'float',34,'/>',10,...
    '                  <param name=',34,'Y',34,' type=',34,'float',34,'/>',10,...
    '                  <param name=',34,'Z',34,' type=',34,'float',34,'/>',10,...
    '               </accessor>',10,...
    '            </technique_common>',10,...
    '       </source>',10,...
    '       <source id=',34,'Plane-Geometry-Normals',34,'>',10,...
    '           <float_array count=',34,num2str(numel(M)),34,' id=',34,'Plane-Geometry-Normals-array',34,'>',NormalsArrayStr,'</float_array>',10,...
    '			<technique_common>',10,...
    '               <accessor count=',34,num2str(numel(M)/3),34,' source=',34,'#Plane-Geometry-Normals-array',34,' stride=',34,'3',34,'>',10,...
    '                  <param name=',34,'X',34,' type=',34,'float',34,'/>',10,...
    '                  <param name=',34,'Y',34,' type=',34,'float',34,'/>',10,...
    '                  <param name=',34,'Z',34,' type=',34,'float',34,'/>',10,...
    '               </accessor>',10,...
    '           </technique_common>',10,...
    '       </source>',10,...
    '       <vertices id=',34,'Plane-Geometry-Vertex',34,'>',10,...
    '           <input semantic=',34,'POSITION',34,' source=',34,'#Plane-Geometry-Position',34,'/>',10,...
    '           <input semantic=',34,'NORMAL',34,' source=',34,'#Plane-Geometry-Normals',34,'/>',10,...
    '       </vertices>',10,...
    '       <triangles count=',34,num2str(length(str2double(locStr))/3),34,' material=',34,'Material_001',34,'>',10,...
    '           <input offset=',34,'0',34,' semantic=',34,'VERTEX',34,' source=',34,'#Plane-Geometry-Vertex',34,'/>',10,...
    '           <p>',locStr,'</p>',10,...
    '       </triangles>',10,...
    '    </mesh>',10,...
    '</geometry>',10,...
    '</library_geometries>',10,...
    '<library_materials>',10,...
    '    <material id=',34,'Material_001',34,' name=',34,'Material_001',34,'>',10,...
    '       <instance_effect url=',34,'#Material_001-fx',34,'/>',10,...
    '    </material>',10,...
    '</library_materials>',10,...
    '<library_visual_scenes>',10,...
    '   <visual_scene id=',34,'Scene',34,' name=',34,'Scene',34,'>',10,...
    '      <node id=',34,'Plane',34,' name=',34,'Plane',34,'>',10,...
    '         <instance_geometry url=',34,'#Plane-Geometry',34,'>',10,...
    '            <bind_material>',10,...
    '               <technique_common>',10,...
    '                  <instance_material symbol=',34,'Material_001',34,' target=',34,'#Material_001',34,'/>',10,...
    '               </technique_common>',10,...
    '            </bind_material>',10,...
    '         </instance_geometry>',10,...
    '      </node>',10,...
    '   </visual_scene>',10,...
    '</library_visual_scenes>',10,...
    '<scene>',10,...
    '   <instance_visual_scene url=',34,'#Scene',34,'/>',10,...
    '</scene>',10,...
    '</COLLADA>'];


fprintf(fid,'%s',xmlStr);
fclose(fid);


end
end

if msgToScreen
   disp(['Generating wind barb Collada models...Done',10])
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                     LOCAL FUNCTIONS                      %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [xCoordsOfBarbs, yCoordsOfBarbs] = ge_windbarb_poly(MX, MY, MU, MV, varargin)
%% ge_windbarb( X, Y, U, V, s01, hemi)
% (MU and MV must be in m/s)
% MX, MY, MX, MY should be the same constructs as used by the quiver
% function.
% AuthorizedOptions = {'barbScale',...
%                      'hemisphere'};

AuthorizedOptions = {'barbScale',...
                     'hemisphere'};

    barbScale = 1;
   hemisphere = 'Auto';

parsepairs %script that parses Parameter/value pairs.

size_MX = size(MX);
size_MY = size(MY);
size_MU = size(MU);
size_MV = size(MV);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% the following block checks whether MX 
%% and MY are both vectors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(size_MX)==2 && any(size_MX==1) 
        % MX is vector
        if length(size_MY)==2 && any(size_MY==1)
            % MY is vector
            [MX,MY] = meshgrid(MX(:),MY(:));
            size_MX = size(MX);
            size_MY = size(MY);
        else
            % MY is not vector        
            error(['Input arguments ' 39 'MX' 39 ' and ' 39 'MY' 39 ' should have ' 10 'the same dimensions. (Error generated by' 10 'function ' mfilename ').' ])
        end
    else
        % MX is not vector
        if length(size_MY)==2 && any(size_MY==1)
            % MY is vector        
            error(['Input arguments ' 39 'MX' 39 ' and ' 39 'MY' 39 ' should have ' 10 'the same dimensions. (Error generated by' 10 'function ' mfilename ').' ])
        else
            % MY is not vector        
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if any([length(size_MX),length(size_MY),length(size_MU),length(size_MV)]>2)
    error(['Function ' 39 mfilename 39 ' is only meant to visualize arrays of' 10 '1 or 2 dimensions.'])
end

if ~isequal(size_MX,size_MY)
    error(['Position input arrays must have identical dimensions. (function:' 39 mfilename 39 ')' ])    
end

if ~isequal(size_MU,size_MV)
    error(['Wind field input arrays must have identical dimensions. (function:' 39 mfilename 39 ')' ])    
end

if ~isequal(size_MX,size_MU)
    error(['Location arrays must have the same dimensions as wind field arrays (function:' 39 mfilename 39 ')' ])    
end


xCoordsOfBarbs = [];
yCoordsOfBarbs = [];

L = prod(size_MU);


for k = 1:L
    
    [xv,yv,knots] = ge_barb_i(MX(k),MY(k),MU(k),MV(k),barbScale,hemisphere);
    
    xCoordsOfBarbs = [xv;NaN;xCoordsOfBarbs];
    yCoordsOfBarbs = [yv;NaN;yCoordsOfBarbs];

end



function [xp,yp,knots] = ge_barb_i(X,Y,U,V,s01,hemi)
% function includes local function:
% speed2knots
% calc_dir
% move_down_stalk
% open_windbarb
% add_flag
% add_whole_pennant
% add_half_pennant
% close_windbarb

% U and V must be multiplied by -1 to account 
% for the fact that windbarb always point 
% into the wind:
U = -U;
V = -V;


WindSpeed = sqrt(U.^2+V.^2);
knots = speed2knots(WindSpeed);

k5 = round(knots/5)*5;
if knots<2.5
    s02 = 0.02*s01;
    xp = [X-s02;X+s02;X+s02;X-s02;X-s02];
    yp = [Y+s02;Y+s02;Y-s02;Y-s02;Y+s02];
    return
end


% number flags
N_flags = floor(k5/50);

% number of whole pennants
N_wpenn = floor((k5-N_flags*50)/10);

% number of half pennants
N_hpenn = floor((k5-N_flags*50-N_wpenn*10)/5);


if ~exist('hemi', 'var')
    hemi = 1;
else
    if strcmp(hemi,'North') || (strcmp(hemi,'Auto') && Y>=0)
        hemi = 1;
    elseif strcmp(hemi,'South') || (strcmp(hemi,'Auto') && Y<0)
        hemi = -1;
    else
        error(['Variable ' 39 'hemi' 39 ' should be one of the following' 10,...
            'char arrays: ' 39 'North' 39 ', ' 39 'South' 39 ', or ' 39 'Auto' 39])
    end
end



d = calc_dir(U,V);
s02 = 0.15*s01;    % width of the flag(s)
s03 = 0.35*s01;    % length of the flag(s)
a_flag = tan(s02/s03);


[xp,yp] = open_windbarb(d,X,Y,s01,hemi);

for i=1:N_flags
   [xp,yp] = add_flag(d,xp,yp,s01,hemi,a_flag);
   if i==N_flags
       [xp,yp] = move_down_stalk(d,xp,yp,s01,hemi);
   end
end


for i=1:N_wpenn
    
    [xp,yp] = add_whole_pennant(d,xp,yp,s01,hemi,a_flag);
    [xp,yp] = move_down_stalk(d,xp,yp,s01,hemi);
    
end

for i=1:N_hpenn
    
    if N_flags==0 && N_wpenn==0
        [xp,yp] = move_down_stalk(d,xp,yp,s01,hemi);
    end

    [xp,yp] = add_half_pennant(d,xp,yp,s01,hemi,a_flag);
    
end

[xp,yp] = close_windbarb(d,xp,yp,s01,hemi);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function K = speed2knots(WS)

f = 0.51; % 1 knot = 0.51 m/s

K = (1/f) * WS;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = calc_dir(U,V)

dy = V;
dx = U;

if (dy==0) && (dx==0)
    error(['Unable to determine the direction of' 10 'a zero-length vector. Function: ' 39 mfilename 39 '.'])
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
function [xv,yv] = move_down_stalk(d,xv,yv,s01,hemi)

s07 = 0.04*s01;    % stalks separation interval

xv = [xv;xv(end) + s07*sin(d+pi)];
yv = [yv;yv(end) + s07*cos(d+pi)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xv,yv] = open_windbarb(d,xv,yv,s01,hemi)

s02 = 0.02*s01;    % width of the flag pole

ax = xv(end) - s02*sin(d+hemi*0.5*pi);
ay = yv(end) - s02*cos(d+hemi*0.5*pi);

bx = ax + s01*sin(d);
by = ay + s01*cos(d);

cx = bx + 2*s02*sin(d+hemi*0.5*pi);
cy = by + 2*s02*cos(d+hemi*0.5*pi);

xv = [xv;ax;bx;cx];
yv = [yv;ay;by;cy];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xv,yv,a_flag] = add_flag(d,xv,yv,s01,hemi,a_flag)



s03 = 0.35*s01;    % length of the flag(s)
s02 = s03*tan(a_flag);    % width of the flag(s)

fx = xv(end) + s03*sin(d+hemi*0.5*pi);
fy = yv(end) + s03*cos(d+hemi*0.5*pi);

gx = xv(end) + s02*sin(d-pi);
gy = yv(end) + s02*cos(d-pi);

xv = [xv;fx;gx];
yv = [yv;fy;gy];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xv,yv] = add_whole_pennant(d,xv,yv,s01,hemi,a_flag)

s02 = 0.34*s01; % stalk length
s03 = 0.03*s01; % stalk width

cx = xv(end) + s03 * sin(d+hemi*pi);
cy = yv(end) + s03 * cos(d+hemi*pi);

ax = xv(end) + s02 * sin(d+hemi*(0.5*pi-a_flag));
ay = yv(end) + s02 * cos(d+hemi*(0.5*pi-a_flag));

bx = ax + s03 * sin(d+hemi*pi);
by = ay + s03 * cos(d+hemi*pi);


xv = [xv;ax;bx;cx];
yv = [yv;ay;by;cy];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xv,yv] = add_half_pennant(d,xv,yv,s01,hemi,a_flag)

s02 = 0.18*s01; % stalk length
s03 = 0.03*s01; % stalk width

cx = xv(end) + s03 * sin(d+hemi*pi);
cy = yv(end) + s03 * cos(d+hemi*pi);

ax = xv(end) + s02 * sin(d+hemi*(0.5*pi-a_flag));
ay = yv(end) + s02 * cos(d+hemi*(0.5*pi-a_flag));

bx = ax + s03 * sin(d+hemi*pi);
by = ay + s03 * cos(d+hemi*pi);


xv = [xv;ax;bx;cx];
yv = [yv;ay;by;cy];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xv,yv] = close_windbarb(d,xv,yv,s01,hemi)

s02 = 0.02*s01;    % width of the flag pole

xv = [xv;xv(1) + s02*sin(d+hemi*0.5*pi);xv(1)];
yv = [yv;yv(1) + s02*cos(d+hemi*0.5*pi);yv(1)];







