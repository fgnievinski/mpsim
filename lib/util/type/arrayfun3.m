function out = arrayfun3 (varargin)
    out = cell2mat(arrayfun2(varargin{:}));
end

