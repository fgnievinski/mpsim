function varargout = get_gnss_power_trend_data (varargin)
    persistent in out nout
    if isequaln(varargin, in) && (nargout == nout),  varargout = out;  return;  end  % faster.
    [varargout{1:nargout}] = get_gnss_power_trend_data_aux (varargin{:});
    in = varargin;
    out = varargout;
    nout = nargout;
end

%%
function varargout = get_gnss_power_trend_data_aux (gnss_name, freq_name, block_name, code_name, subcode_name)
    if (nargin < 1),  gnss_name = [];  end
    if (nargin < 2),  freq_name = [];  end
    if (nargin < 3),  block_name = [];  end
    if (nargin < 4),  code_name = [];  end
    if (nargin < 5),  subcode_name = [];  end
    
    switch upper(gnss_name)
    case 'GPS',  fnc = @get_gps_power_trend_data;  argin = {freq_name, block_name, code_name, subcode_name};
    case 'GLO',  fnc = @get_glo_power_trend_data;  argin = {freq_name, code_name};
    end

    [varargout{1:nargout}] = fnc (argin{:});
end
