function [Unmatched, Results] = plotsinaux2 (Defaults, varargin)
  %persistent warned_already
  %if isempty(warned_already),  warned_already = false;  end
  warned_already = false;  % force repeated warnings.
  
  try
    p = inputParser2();
  catch err
    if ~is_error_undefined_function (err),  rethrow(err);  end
    Results = Defaults;
    Unmatched = struct();
    if (nargin > 0),  Results.LineSpec = varargin{1};  end
    if ~warned_already
      msg = 'Missing inputParser library.';
      if ~isempty(varargin)
        msg = [msg(1:end-1) '; ignoring plotsin customization.'];
      end
      warning ('snr:plotsin:noInputParser', msg);
      warned_already = true;
    end
    return
  end
    
  p.addOptional('LineSpec',Defaults.LineSpec, @(x) ischar(x) && (numel(x) <= 4));
  p.addParamValue('etick',Defaults.etick, @(x) isvector(x) && isnumeric(x));
  p.addParamValue('eticktolabel',Defaults.eticktolabel, @(x) isvector(x) && isnumeric(x) || ischar(x));
  p.addParamValue('etick2label', Defaults.eticktolabel, @(x) isvector(x) && isnumeric(x) || ischar(x));  % LEGACY
  p.addParamValue('format',Defaults.format, @(x) isvector(x) && ischar(x));
  p.addParamValue('xlabel',Defaults.xlabel, @(x) ischar(x) || isempty(x));
  p.KeepUnmatched = true;
  
  p.parse(varargin{:});
  if ~isfieldempty(p.Results, 'etick2label') ...
  && ~isequaln(p.Results.etick2label, Defaults.eticktolabel) ...      
  && ~isequaln(p.Results.etick2label, p.Results.eticktolabel)
    warning('snr:plotsin:deprecated', ...
      'Deprecated syntax "etick2label"; please use "eticktolabel" instead.');
  end  
  
  Results = p.Results;
  Unmatched = p.Unmatched;
  
  dispose(p)
end
