function ge_output(filename,output,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_output.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%



AuthorizedOptions = authoptions( mfilename );


% Assign default values to parameters:
       name = filename;
msgToScreen = false;
    
parsepairs %script that parses Parameter/value pairs.

if msgToScreen
   disp(['Running ' mfilename '...']) 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileoutput = filename( (end-2):end );

if strcmp(fileoutput,'kml')

    fid = fopen(filename, 'wt');

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

elseif strcmp(fileoutput,'kmz')
  
    newfilename = filename(1:(end-4));
    newfilename = strcat(newfilename,'.kml');
    
    fid = fopen( newfilename, 'wt');

    header = ['<?xml version="1.0" encoding="UTF-8"?>',10,...
             '<kml xmlns="http://earth.google.com/kml/2.1">',10,...
             '<Document>',10,...
             '<name>',10,name,10,'</name>',10];
    footer = [10,'</Document>',10,...
        '</kml>',10];

    fprintf(fid,'%s',header);
    fprintf(fid,'%s',output);
    fprintf(fid,'%s',footer);
    fclose(fid);
    
    
    zip(filename,newfilename);
    
    if ispc
        system(['del ',newfilename] );
        system(['move ',filename, '.zip ', filename]);
    else
        system(['rm -f ',newfilename]);
        system(['mv ',filename, '.zip ', filename]);
    end
   
else
    error('unsupported file extension used in ge_output');
end


if msgToScreen
   disp(['Running ' mfilename '...Done']) 
end