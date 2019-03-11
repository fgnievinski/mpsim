function mysaveas (varargin)
%MYSAVEAS  Save figure as an image, with persistent settings.
% 
% SYNTAX:
%    mysaveas ()
%    mysaveas (true)
%    mysaveas (false)
%    mysaveas (basename, format, width, resol, dir)
%
% INPUT:
%    true/false: [logical scalar] enable/disable file saving; "false" means ignore save command
%    basename: [char] image basename, i.e., filename without directory and extension
%    format: [char] image format; see "doc print" for options; the extension follows from format
%    format: [cell] image formats; as a cell array of character strings
%    width: [char] image width (in pixels)
%
% OUTPUT: none
%
% REMARKS:
% - Input an empty value to reuse previously input value for a given argument.
% 
% SEE ALSO: print

    %%
    persistent enabled
    if isempty(enabled),  enabled = true;  end
    if (nargin > 0) && islogical(varargin{1})
        enabled = varargin{1};
        mysaveas ();
        return
    end
    if (nargin == 0)
        fprintf('%s %s.\n', mfilename(), logical2onoff(enabled));
        return;
    end
    if ~enabled,  return;  end
    mysaveasaux2 (varargin{:})
end

%%
function mysaveasaux2 (basename, format_input, width_input, resol_input, dir_input)
    format_default = {'png','epsc'};
    width_default = [];  % in cm.
    %width_default = 8.4;  % in cm.
    resol_default = 150;
    if (nargin < 2),  format_input = [];  end
    if (nargin < 3),   width_input = [];  end
    if (nargin < 4),   resol_input = [];  end
    if (nargin < 5),     dir_input = [];  end
    persistent format_persist width_persist resol_persist dir_persist
    if isempty(format_persist),  format_persist = format_default;  end
    if isempty(width_persist),    width_persist =  width_default;  end
    if isempty(resol_persist),    resol_persist =  resol_default;  end
    if ~isempty(format_input),  format_persist = format_input;  end
    if ~isempty( width_input),   width_persist =  width_input;  end
    if ~isempty( resol_input),   resol_persist =  resol_input;  end
    if ~isempty(   dir_input),     dir_persist =    dir_input;  end
    if (nargin < 1) || isempty(basename),  return;  end
    mysaveasaux (basename, format_persist, width_persist, resol_persist, dir_persist)
end

%%
function mysaveasaux (basename, format, width, resol, dir)
    %fixfig()
    if ~isempty(width) && ~isnan(width),  fig(gcf(), 'Width',width);  end
    if ~iscell(format),  format = {format};  end
    idx = strcmpi(format, 'eps');
    if any(idx)
      warning('MATLAB:mysaveas:eps', ...
        'MATLAB print format "eps" is unreliable; using format "epsc2" instead (file extension remains "eps").');
      format{idx} = 'epsc2';
    end  
    ext = format;  ext(ismember(format, {'epsc','eps2','epsc2'})) = {'eps'};
    filepath = fullfile(char(dir), basename);
    mysaveaux3 = @(ext, format) print(gcf(), [filepath '.' ext], ['-d' format], ['-r' num2str(resol)]);%, '-zbuffer');
    cellfun(mysaveaux3, ext, format);
end
