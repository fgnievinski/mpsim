function foutput = ge_folder(foldername,output)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_folder.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%

header = ['<Folder id="' foldername '">',...
         '<name>',foldername,'</name>'];
footer = '</Folder>';

foutput = [header output footer];

