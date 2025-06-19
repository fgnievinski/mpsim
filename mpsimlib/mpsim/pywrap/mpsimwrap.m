function outstrc = mpsimwrap(mpsimfunc, varargin)

nout=nargout(mpsimfunc);

if nargin == 1
    %no additional arguments provided
    if nout == 0
        outstrc = feval(mpsimfunc);
    else

        outstrc=sanitize4py(feval(mpsimfunc));
    endif
else

    % possibly sanitize (variable) input arguments 
    for i = 1:length(varargin)
        if isstruct(varargin{i})
            varargin{i} = sanitize4oct(varargin{i});
        end
    end
    if nout == 0
        feval(mpsimfunc, varargin{:});
    else
        outstrc = sanitize4py(feval(mpsimfunc, varargin{:}));
    endif
endif




endfunction
