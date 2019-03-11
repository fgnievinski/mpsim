function open_print_doc()
%This file is used by 'html/print_doc_index.html' to open up a pdf file.
p=mfilename('fullpath');
[ppath,name,ext,vrsn]=fileparts(p);
docURL = [char(39),ppath,filesep,'doc',filesep,'Google Earth Toolbox tutorial.pdf',char(39)];

if ispc
    eval(['winopen(',docURL,')'])
else
    disp(['Focus will be returned to MATLAB after closing',...
        char(10),'the external application.'])
    eval(['[s,cdir]=system(',docURL,');'])
end