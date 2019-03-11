function s=googleearthroot()
a=mfilename('fullpath');
Ix=findstr(a,filesep);
s=a(1:Ix(end));

