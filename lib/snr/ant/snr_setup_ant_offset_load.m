function data = snr_setup_ant_offset_load (data_dir, filename)
    if (nargin < 1) || isempty(data_dir),  data_dir = snr_setup_ant_path();  end
    if (nargin < 2) || isempty(filename),  filename = 'antenna_offset.txt';  end
    filepath = fullfile(data_dir, filename);
    
    persistent data0 filepath0 moddate0
    if ~isempty(data0) && strcmp(filepath0, filepath) ...
    && strcmp(moddate0, getfield(dir(filepath), 'date'))
        data = data0;
        return;
    end
    
    data = snr_setup_ant_offset_load_aux (filepath);
    data0 = data;
    filepath0 = filepath;
    moddate0 = getfield(dir(filepath), 'date');
end

function data = snr_setup_ant_offset_load_aux (filepath)
    [fid, msg] = fopen(filepath, 'r');
    if (fid == -1)
        error('MATLAB:couldNotReadFile', ...
            'Unable to read file "%s": %s.', ...
            filepath, msg);
    end
    format = '%s %s %s %f %f %f';
    %temp = 'TRM29659.00  SCIT  L1   1.50      0.44     88.04';
    %data = textscan(temp, format, ...
    data = textscan(fid, format, ...
      'Delimiter',' ',  'MultipleDelimsAsOne',true, ...
      'CommentStyle','%');
    fclose(fid);
    assert(is_uniform(cellfun(@numel, data)))
    f = {'antenna', 'radome', 'freq_name', 'north', 'east', 'up'};
    data = cell2struct(data, f, 2);
    % convert from mm to meters:
    data.north = data.north ./ 1e3;
    data.east  = data.east  ./ 1e3;
    data.up    = data.up    ./ 1e3;
    data.filepath = filepath;
end

