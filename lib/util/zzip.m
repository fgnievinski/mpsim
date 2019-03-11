function filenames_out = zzip (filenames, outputdir, opt)
% TODO: test errors.
    % we assume that compress lives in the same directory as this m-file.
    ext = '';  if ispc,  ext = '.exe';  end
    cmd = fullfile(fileparts(mfilename('fullpath')), ['compress', ext]);
    if ~exist(cmd, 'file')
        error('MATLAB:zzip:compress', 'compress not found in "%s"', cmd);
    end

    if (nargin < 2),  outputdir = [];  end
    if (nargin < 3),  opt = '';  end

    if ~iscell(filenames),  filenames = {filenames};  end
    if (nargout > 0),  filenames_out = cell(size(filenames));  end
    for i=1:length(filenames),  filename = filenames{i};  

    if ~exist(filename, 'file')
        error('MATLAB:zzip:file', 'File "%s" not found.', file);
    end

    if strcmp(fileparts(filename), outputdir),  outputdir = [];  end
    if ~isempty(outputdir)
        copyfile(filename, outputdir);
        [temp1, temp2, temp3] = fileparts(filename);
        filename = fullfile(outputdir, [temp2, temp3]);
    end

    tmpname = tempname;
    if strcmp(opt, '-d')
        tmpname = [tmpname, '.Z'];
    end
    %tmpname  % DEBUG
    copyfile(filename, tmpname);
    cmd2 = [cmd ' ' opt ' ' tmpname];
    [status, result] = system(cmd2);
    if (status ~= 0)
        error('MATLAB:zzip:system', 'Error calling "%s"', cmd2);
    end
    if strcmp(opt, '-d')
        % discard '.Z'
        tmpname = tmpname(1:end-2);
        filename_out = filename(1:end-2);
    else
        tmpname = [tmpname, '.Z'];
        filename_out = [filename, '.Z'];
    end
    %tmpname, filename_out  % DEBUG
    movefile(tmpname, filename_out);
    % Aboe, instead of copying the file to a temporary file, 
    % we tried using redirection. It seems the newline characters is wrong.
    %cmd2 = [cmd ' ' opt ' -c ' filename ' > ' filename_out];

    if ~isempty(outputdir)
        delete(filename);
    end
    
    if (nargout > 0)
        filenames_out{i} = filename_out;
    end

    end  % for i=1:length(filenames)
    %if (nargout > 0) && (length(filenames) == 1)
    %    filenames_out = filenames_out{1};
    %end
end

%!shared
%! text = 'files is a string or cell array of strings containing a list of files or directories to gzip. Individual files that are on the MATLAB path can be specified as partial pathnames. Otherwise an individual file can be specified relative to the current directory or with an absolute path. Directories must be specified relative to the current directory or with absolute paths. On UNIX systems, directories can also start with ~/ or ~username/, which expands to the current user';
%! n = ceil(10*rand);
%! %filenames = cellfun(@(x) tempname, num2cell(1:n), 'UniformOutput',false);
%! for i=1:n;
%!     filenames{i} = tempname;
%!     fid = fopen(filenames{i}, 'wt+');
%!     fprintf(fid, '%s\n', text);
%!     fclose(fid);
%! end
%! %filenames{:},  pause  % DEBUG

%!test
%! % compression
%! filenames2 = zzip(filenames);
%!   cellfun(@(f) delete(f), filenames);
%! output_exist = cellfun(@(f) exist(f, 'file'), filenames2);
%!   cellfun(@(f) delete(f), filenames2);
%! myassert(all(output_exist))

%!test
%! % decompression
%! %filenames,  pause
%! filenames2 = zzip(filenames);
%! %filenames2,  pause
%!   cellfun(@(f) delete(f), filenames);
%! filenames3 = zunzip(filenames2);
%! %filenames3,  pause
%!   cellfun(@(f) delete(f), filenames2);
%! output_exist = cellfun(@(f) exist(f, 'file'), filenames3);
%!   cellfun(@(f) delete(f), filenames3);
%! myassert(all(output_exist))

%!test
%! % case in which outputdir ~= fileparts(filename).
%! outputdir = tempname;
%! mkdir(outputdir);
%! filenames_out = zzip(filenames, outputdir);
%! %filenames_out{:}, pause
%! output_exist = cellfun(@(f) exist(f, 'file'), filenames_out);
%!   cellfun(@(f) delete(f), filenames_out);
%!   rmdir(outputdir);
%! myassert(all(output_exist))

