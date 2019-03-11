function open_content_html()
%This file is used to open up a 'html/contents.html' from 'Contents.m'.
p=mfilename('fullpath');
[ppath,name,ext,vrsn]=fileparts(p);
docURL = [ppath,filesep,'html',filesep,'contents.html'];
web(docURL,'-helpbrowser')