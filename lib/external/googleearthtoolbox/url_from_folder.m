function URL=url_from_folder(F,S)

p=mfilename('fullpath');
[ppath,name,ext,vrsn]=fileparts(p);
URL = [ppath,filesep,F,filesep,S];
if isdir(URL)&&URL(end)~=filesep
    URL=[URL,filesep];
end
    