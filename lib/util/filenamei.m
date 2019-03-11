function [filepath, found] = filenamei (filepath)
    [dirpath, filename] = fileparts2(filepath);
    temp = dir(dirpath);  filenames = {temp(:).name};
    idx = strcmpi(filenames, filename);
    found = any(idx);
    if ~found,  return;  end
    filename = filenames{find(idx,1)};
    filepath = fullfile(dirpath, filename);
end

%!test
%! filepath_good = which(mfilename());
%! if isempty(filepath_good),  filepath_good = which('filenamei');  end
%! [dirpath, filename_good] = fileparts2(filepath_good);
%! filename_bad = shuffle(filename_good);
%! filepath_bad = fullfile(dirpath, filename_bad);
%! [filepath_found, found] = filenamei (filepath_bad);
%! %filepath_good, filepath_bad, filepath_found  % DEBUG
%! assert(strcmp(filepath_found, filepath_good));
