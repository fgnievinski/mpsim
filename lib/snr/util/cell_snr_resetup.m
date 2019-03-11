function [setup, sett] = cell_snr_resetup (sett, setup, varargin)
    siz = size(sett);
    if isempty(sett),  setup = cell(siz);  return;  end
    if (nargin < 2),  setup = [];  end
    if isempty(setup),   setup = snr_setup(sett{1});  end
    if ~iscell(setup),   setup = {setup};  end
    if isscalar(setup),  setup = repmat(setup, siz);  end
    fnc = @(setti, setupi) snr_resetup(setti, setupi, varargin{:});
    setup = cellfun2(fnc, sett, setup);
    %for i=1:prod(siz)
    %    setup{i} = snr_resetup (sett{i}, setup{i}, varargin{:});
    %end        
end    
