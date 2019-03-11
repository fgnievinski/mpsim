function open_demo(S)
%This file is used to open up the specified demo "S"
p=mfilename('fullpath');
[ppath,name,ext,vrsn]=fileparts(p);
docURL = [ppath,filesep,'demo',filesep,S];
edit(docURL)