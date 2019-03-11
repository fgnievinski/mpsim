function filename = snr_setup_ant_filename (...
comp_type, model, radome, freq_name, polar)
    model = strrep(model, '/', '_');
    ext = 'dat';
    sep = '__';
    filename = cell2mat({model sep radome sep freq_name sep polar sep comp_type '.' ext});
    filename = upper(filename);
end

