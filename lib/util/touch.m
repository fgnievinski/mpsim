function touch (filepath, dir)
    if (nargin > 1)
        if isempty(dir),  dir = fileparts(filepath);  end
        if ~exist(dir, 'dir'),  mkdir(dir);  end
    end
    fclose(fopen(filepath, 'w'));
end
