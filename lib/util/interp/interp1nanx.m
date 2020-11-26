function varargout = interp1nanx (x, y, varargin)
% see also: naninterp1
    idx = isnan(x);% | isnan(y);
    x(idx) = [];
    if ~isvector(y),  assert(size(y,1) == numel(x));  end
    y(idx,:) = [];
    s1 = warning('off', 'MATLAB:interp1:NaNinY');
    s2 = warning('off', 'MATLAB:chckxy:IgnoreNaN');    
    s3 = warning('off', 'MATLAB:interp1:NaNstrip');
    [varargout{1:nargout}] = interp1 (x, y, varargin{:});
    warning(s1);
    warning(s2);
    warning(s3);
end


