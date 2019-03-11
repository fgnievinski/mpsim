function ge_writecollada(varargin)

% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_writecollada.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%

AuthorizedOptions = authoptions(mfilename);


modelStyle = 'arrow-style-001';
faceColor = [0,0.5,0];
faceAlpha = 0.2;
daeFileName = 'collada-tmp.dae';

parsepairs %script that parses Parameter/Value pairs.

switch modelStyle
    case 'arrow-style-001'
        daeFileNameTemplate = 'arrow-style-001.dae';
        colladaValues = [faceColor,faceAlpha];
    case 'arrow-style-002'
        daeFileNameTemplate = 'arrow-style-002.dae';
        colladaValues = [faceColor,faceAlpha];        
    case 'cone-style-001'
        daeFileNameTemplate = 'cone-style-001.dae';
        colladaValues = [faceColor,faceAlpha];        
end

fileStr=fullfile(ge_root,'data',...
    'collada-model-templates',daeFileNameTemplate);

try
    fid=fopen(fileStr,'r');
    n=0;
    while true
        n=n+1;
        txtLines{n,1} = fgetl(fid);
        if feof(fid)
            break
        end
    end
    fclose(fid);
catch
    error('Error reading template COLLADA file.')
end

colladaTagStr='';
for k=1:n
    colladaTagStr = [colladaTagStr,txtLines{k,1},char(10)];
end

fid=fopen(daeFileName,'wt');
fprintf(fid,colladaTagStr,colladaValues);
fclose(fid);

