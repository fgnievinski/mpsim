function filename = write_to_temp_file (file_contents)
    myassert(iscell(file_contents));
    filename = tempname;
    fid = fopen(filename, 'wt');
    if (fid == -1)
        error ('MATLAB:write_to_temp_file:fopen', ...
            'Couldn''t open file %s. %s', filename, temp_msg);
    end
    for i=1:length(file_contents)
        fprintf (fid, '%s\n', file_contents{i});
    end
    fclose(fid);
end

