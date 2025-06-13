function varargout = get_gnss_constant (gnss_name, freq_name, channel, quantity)
    if (nargin < 1),  gnss_name = [];  end
    if (nargin < 2),  freq_name = [];  end
    if (nargin < 3),  channel = [];  end
    if (nargin < 4) || isempty(quantity),  quantity = 'wavelength';  end

    switch upper(gnss_name)
    case 'GPS',  fnc = @get_gps_constant;  argin = {freq_name, quantity};
    case 'GLO',  fnc = @get_glo_constant;  argin = {freq_name, channel, quantity};
    end

    [varargout{1:nargout}] = fnc (argin{:});
end

