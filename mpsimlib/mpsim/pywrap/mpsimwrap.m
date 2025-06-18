function outstrc = mpsimwrap(mpsimfunc, varargin)

if length(varargin) == 1 && iscell(varargin{1})
    % If the first argument is a cell array, unpack it
    outstrc = sanitize4py(feval(mpsimfunc, sanitize4oct(varargin{1})));
elseif length(varargin) > 1
    % If there are multiple arguments, unpack them
    error("cannot currently wrap functions with multiple input arguments");
else
    outstrc=sanitize4py(feval(mpsimfunc));
endif
