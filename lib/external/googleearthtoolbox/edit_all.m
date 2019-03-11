function edit_all(dirStr)
%Opens up all .m files present in directory dirStr 
%with filenames starting with 'ge_'.
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%


dir_struct = dir(dirStr);

for k=3:length(dir_struct)
    if length(dir_struct(k).name)>=3&&...
       strcmp(dir_struct(k).name(1:3),'ge_')&&...
       strcmp(dir_struct(k).name(end-1:end),'.m')
   
        eval(['edit ',dir_struct(k).name(1:end-2)])
    end
end