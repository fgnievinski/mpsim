function ge_kml(kmlFileName,output,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_kml.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


AuthorizedOptions = authoptions( mfilename );

% Assign default values to parameters:
       name = kmlFileName;
msgToScreen = false;
kmlTargetDir = [pwd,filesep];

p = mfilename('fullpath');
[toolboxroot, pname, ext, versn]=fileparts(p);

parsepairs %script that parses Parameter/value pairs.

if msgToScreen
   disp(['Running ' mfilename '...']) 
end

if ~isequal(kmlTargetDir(end),filesep)
    kmlTargetDir(end+1)=filesep;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileExt = kmlFileName(end-2:end);

if strcmp(fileExt,'kml')

    fid = fopen([kmlTargetDir,kmlFileName], 'wt');

    header = ['<?xml version="1.0" encoding="UTF-8"?>',10,...
             '<kml xmlns="http://earth.google.com/kml/2.1">',10,...
             '<Document>',10,...
             '<name>',10,name,10,'</name>',10];
    footer = [10,'</Document>',10,...
        '</kml>'];

    fprintf(fid,'%s',header);
    fprintf(fid,'%s',output);
    fprintf(fid,'%s',footer);
    fclose(fid);

else
    error(['unsupported file extension used in function' mfilename]);
end


if msgToScreen
   disp(['Running ' mfilename '...Done']) 
end