base_dir = fileparts(mfilename('fullpath'));
lib_dir = fullfile(base_dir, 'lib');
scr_dir = fullfile(base_dir, 'script');
img_dir = fullfile(base_dir, 'image');

addpath(genpath(lib_dir))
addpath(genpath(scr_dir))
%addpath(genpath(base_dir))  % WRONG!
addpath(base_dir)
if is_octave()
  tmp = which('isequaln');
  tmp2 = [tmp '.off'];
  if strstart(lib_dir, fileparts(tmp))
    if exist(tmp2, 'file')
      delete(tmp2)
    end
    rename(tmp, tmp2);
  end
  clear tmp tmp2
  struct_levels_to_print (0);
  try pkg load statistics catch, end
end
warning('off','snr:setup_ant_comp:noPre')
cd(scr_dir)

init_plot
