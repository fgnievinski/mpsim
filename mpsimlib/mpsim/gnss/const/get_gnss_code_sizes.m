function varargout = get_gnss_code_sizes (gnss_name, code_name, subcode_name, freq_name)
    if (nargin < 1),  gnss_name = [];  end
    if (nargin < 2),  code_name = [];  end
    if (nargin < 3),  subcode_name = [];  end
    if (nargin < 4),  freq_name = [];  end

    switch upper(gnss_name)
    case 'GPS',  fnc = @get_gps_code_sizes;  argin = {code_name, subcode_name, freq_name};
    case 'GLO',  fnc = @get_glo_code_sizes;  argin = {code_name};
    end
    
    [varargout{1:nargout}] = fnc (argin{:});
end

