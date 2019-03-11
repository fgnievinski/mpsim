% (generalized as colormbl.m)
function [h, cmap] = colormap_bwr_it (varargin)
    error(nargchk(0, 6, nargin, 'struct'));
    
    persistent cmap_bwr
    if isempty(cmap_bwr),  cmap_bwr = bwr();  end
    cmap = cmap_bwr;
    if (nargin == 2) && strcmp(varargin{1}, 'cmap')
        cmap = varargin{2};
        return;
    end
    
    f = 1;
    clim = [];
    clab = [];
    clab = 'symm';
    ctit = [];
    switch nargin
    case 0
        ax = [];
        data = [];
    case 1
        ax = [];
        data = varargin{1};
    case 2
        ax = varargin{1};
        data = varargin{2};
    case 3
        ax = varargin{1};
        data = varargin{2};
        f = varargin{3};
    case 4
        ax = varargin{1};
        data = varargin{2};
        f = varargin{3};
        clim = varargin{4};
    case 5
        ax = varargin{1};
        data = varargin{2};
        f = varargin{3};
        clim = varargin{4};
        clab = varargin{5};
    case 6
        ax = varargin{1};
        data = varargin{2};
        f = varargin{3};
        clim = varargin{4};
        clab = varargin{5};
        ctit = varargin{6};
    end
    
    colormap(cmap)
    h = colorbar();
    colorlim(data, f, ax, h, clim, clab, ctit);
    if (nargout < 1),  clear h;  end
end
