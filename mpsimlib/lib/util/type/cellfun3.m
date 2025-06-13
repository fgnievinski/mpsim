function out = cellfun3 (varargin)
    out = cell2mat(cellfun2(varargin{:}));
end

