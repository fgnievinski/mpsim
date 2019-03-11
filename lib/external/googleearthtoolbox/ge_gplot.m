function output = ge_gplot(A, Vertices, varargin)% 
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_gplot.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%

AuthorizedOptions = authoptions( mfilename );

                 
         id   = 'gplot';
      idTag   = 'id';
       name   = 'ge_gplot';
description   = '';
     snippet  = ' ';
    timeStamp = ' ';
timeSpanStart = ' ';
 timeSpanStop = ' ';
 visibility   = 1;
  lineColor   = 'ffffffff';
  lineWidth   = 1.0;
   altitude   = 1;
 altitudeMode = 'clampToGround';
 msgToScreen  = false;
 region = ' ';
 forceAsLine  = false; % Reduces file size with no loss in...
                      % accuracy, i.e. as long as all lines...
                      % have only 1 segment.
 tessellate = 1;
 extrude = 0;
 
parsepairs %script that parses Parameter/value pairs.

if msgToScreen
    disp(['Running: ',mfilename,'...'])
end

if ( isempty( A ) | isempty(Vertices) )
    error('empty coordinates passed to ge_gplot(...).');
end


if ~(isequal(altitudeMode,'clampToGround')||...
   isequal(altitudeMode,'relativeToGround')||...
   isequal(altitudeMode,'absolute'))

    error(['Variable ',39,'altitudeMode',39, ' should be one of ' ,39,'clampToGround',39,', ',10,39,'relativeToGround',39,', or ',39,'absolute',39,'.' ])
    
end


% It used to say here:
% [i,j] = find(A);
% but that would unnecessarily double the number of points.

[i,j] = find(triu(ones(size(A))).*A);
[ignore, p] = sort(max(i,j));
i = i(p);
j = j(p);

% Create a long, NaN-separated list of line segments,
% rather than individual segments.

X = [ Vertices(i,1) Vertices(j,1) repmat(NaN,size(i))]';
Y = [ Vertices(i,2) Vertices(j,2) repmat(NaN,size(i))]';
X = X(:);
Y = Y(:);

output = ge_plot(X,Y, ...
                'name', name, ...
                'snippet', snippet, ...
                'description', description, ...
                'region', region, ...
                'timeStamp', timeStamp, ...
                'timeSpanStart', timeSpanStart, ...
                'timeSpanStop', timeSpanStop, ...
                'visibility', visibility, ...
                'lineColor', lineColor, ...
                'lineWidth', lineWidth,...
                'altitude',altitude,...
                'altitudeMode',altitudeMode,...
                'extrude',extrude,...
                'tessellate',tessellate,...
                'forceAsLine',forceAsLine);


if msgToScreen
    disp(['Running: ' mfilename,'...Done'])
end
