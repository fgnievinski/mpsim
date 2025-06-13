function kmlStr=ge_scatter(X,Y,varargin)

X = X(:);
Y = Y(:);

AuthorizedOptions = authoptions(mfilename);

styleId = 'style';
markerEdgeColor = 'FF00FFFF';
markerFaceColor = 'FF00FFFF';
lineWidth = '3';
styleMapId = ['styleMapId','-',styleId];
tesselate = 1;
marker = 's';
markerScale = 1;
altitudeMode = 'clampToGround'; 

parsepairs
if ~(exist('xUnitShape', 'var') && exist('yUnitShape', 'var'))
    switch marker
        case 'o'
            % circle
            xUnitShape = sin(linspace(0,2*pi,21))';
            yUnitShape = cos(linspace(0,2*pi,21))';
        case 's'
            % square
            xUnitShape = -0.5+[1,1,0,0,1]';
            yUnitShape = -0.5+[1,0,0,1,1]';
        case 'd'
            % diamond
            xUnitShape = [0,0.5,0,-0.5,0]';
            yUnitShape = [1,0,-1,0,1]';
        case '*'
            % star
            rads = linspace(0,2*pi,6);
            xRads = [1*sin(rads);0.4*sin(rads+0.2*pi)];
            yRads = [1*cos(rads);0.4*cos(rads+0.2*pi)];
            xUnitShape = xRads(:);
            yUnitShape = yRads(:);
            
            clear xRads yRads rads
    end
end

if strcmp(markerFaceColor,'none')
    markerFaceColor = '00000000';
end

if strcmp(markerEdgeColor,'none')
    markerEdgeColor = '00000000';
end


xUnitShape = markerScale*xUnitShape(:);
yUnitShape = markerScale*yUnitShape(:);



kmlStr = ...
['	<Style id=',char(39),styleId,char(39),'>',char(10),...
'		<LineStyle>',char(10),...
'			<color>',markerEdgeColor([1,2,7,8,5,6,3,4]),'</color>',char(10),...
'			<width>',lineWidth,'</width>',char(10),...
'		</LineStyle>',char(10),...
'		<PolyStyle>',char(10),...
'			<color>',markerFaceColor([1,2,7,8,5,6,3,4]),'</color>',char(10),...
'		</PolyStyle>',char(10),...
'	</Style>',char(10),...
'	<StyleMap id=',char(39),styleMapId,char(39),'>',char(10),...
'		<Pair>',char(10),...
'			<key>normal</key>',char(10),...
'			<styleUrl>#',styleId,'</styleUrl>',char(10),...
'		</Pair>',char(10),...
'		<Pair>',char(10),...
'			<key>highlight</key>',char(10),...
'			<styleUrl>#',styleId,'</styleUrl>',char(10),...
'		</Pair>',char(10),...
'	</StyleMap>'];

L = numel(kmlStr);
N = numel(X);


for k=1:N

    placemarkName = ['scatter-',num2str(k)];

    xCoordinates = X(k)+xUnitShape;
    yCoordinates = Y(k)+yUnitShape;
    
    coordinates = rot90([xCoordinates,yCoordinates,zeros(size(xCoordinates))],-1);
    coordinatesStr = sprintf('%f,%f,%f \r',coordinates);

    kmlStrPlacemark = ['<Placemark>',char(10),...
    '	<name>',placemarkName,'</name>',char(10),...
    '	<styleUrl>#',styleId,'</styleUrl>',char(10),...
	'	<Polygon>',char(10),...
    '   <altitudeMode>',altitudeMode,'</altitudeMode>',char(10),...
    '		<tessellate>',num2str(tesselate),'</tessellate>',char(10),...
	'		<outerBoundaryIs>',char(10),...
	'			<LinearRing>',char(10),...
    '		<coordinates>',char(10),...
    coordinatesStr,char(10),...    
    '       </coordinates>',char(10),...
	'			</LinearRing>',char(10),...
	'		</outerBoundaryIs>',char(10),...
	'	</Polygon>',char(10),...
    '</Placemark>',char(10)];

    if k==1
        L = numel(kmlStrPlacemark);
        pos = numel(kmlStr);
        kmlStr = [kmlStr,repmat(' ',[1,L*N])];
    end
    
    kmlStr(pos+1:pos+numel(kmlStrPlacemark)) = kmlStrPlacemark;
    pos = pos + numel(kmlStrPlacemark);

end