function data_dir = snr_setup_ant_path ()
    persistent data_dir_old
    if isempty(data_dir_old)
      data_dir_old = fullfile(dirup(fileparts(which(mfilename()))), 'data', 'ant');
    end
    data_dir = data_dir_old;
end
