if isunix()
  m_dir = '/home/xenon/student/nievinsk/work/software/m/';
else
  m_dir = 'c:\work\m\';
end
addpath(genpath(m_dir))
if isunix(),  set(0, 'DefaultFigureRenderer','zbuffer');  end  % may be necessary if video driver makes matlab crash
set(0, 'DefaultFigureVisible','off');
% set(0, 'DefaultFigureVisible','on');
set(0,'DefaultAxesFontSize',16)

dem_suffix = 'NED19';
dem_suffix = []  % accept defaults

crop_width = 500;  % 500 means a 500-by-500 meters square centered at the station
crop_width = Inf;  % Inf means maximum rectangular extent even if that includes pixels with missing height.
crop_width = 0;    % 0 means maximum rectangular extent excluding pixels with missing height.
crop_width = [];   % empty means accept defaults.
crop_width = [500, 200, 100];  % you can ask for more than one for plotting.
crop_width_fit = [500, 200, 100];

azim_mid = 0:45:360;  % vector with azimuth mid values where individual plane fits will be centered.
azim_tol = [180, repmat(45/2, [1,numel(azim_mid)-1])];  % vector with tolerances for each azimuthal slice (180 means entire plane, 45/2 means 45-degree slices).

cmap = 'dkbluered';
cmap = 'jet';
cmap = {'dkbluered', 'jet'};

% site = struct();
% % my test
% site.code = 'p101';
% abc = getsiteinfo(site.code);
% site.lat = abc.lat;
% site.lon = abc.wlon;
% site.h = abc.el;
% % site.code = 'bcgr';
% % site.lat = 40.031151;
% % site.lon = -105.169987;
% % site.h = 1559.4;
% % felipe's test
% %site.code = 'p208';
% %site.lat = 39.109302;
% %site.lon = -122.303869;
% %site.h = 74.3;
% dem = do_dem_aux (site, crop_width, cmap);

log_file = fullfile(dem_path([], 'log', dem_suffix), 'log.txt');
diary off
if exist(log_file, 'file'),  delete(log_file);  end
diary(log_file)

%% get list of files to process:
temp = dir(fullfile(dem_path([], 'zip', dem_suffix), '*.zip'));
temp = {temp(:).name};
temp = cellfun(@(x) x(1:4), temp(:), 'UniformOutput',false);
code_all = temp;

skip_already_done = false;
% skip_already_done = true;
skip_upto_code = [];
%skip_upto_code = 'P500';  % DEBUG

do_fit_only = true;
do_fit_only = false;

site = struct();
dem = [];
for i=1:numel(code_all)
  disp(code_all{i})
  site.code = code_all{i};
  if strcmpi(site.code, skip_upto_code),  skip_upto_code = '';  end  % DEBUG
  if ~isempty(skip_upto_code),  continue;  end  % DEBUG
  
  temp = getsiteinfo(site.code);
  if ~isfield(temp, 'el')
    warning('snr:dem:do_dem:noSiteInfo', ...
      'No info in master list for site "%s".', site.code);
    continue;
  end
  
  site.lat = temp.lat;
  site.lon = temp.wlon;
  site.h = temp.el;
  if ~do_fit_only
    dem = do_dem_aux (site, crop_width, cmap, dem_suffix, skip_already_done);
  end
  fit = do_dem_fit (site, dem, crop_width_fit, azim_mid, azim_tol, dem_suffix);
  
  if ~isempty(dem),  fprintf('%s\n', code_all{i});  end
  %pause  % DEBUG
  close all
end

diary off

