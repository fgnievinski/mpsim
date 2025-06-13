function out = structcellfun (fnc, in, varargin)
    out = structfun2 (@(fld) cellfun (fnc, fld, varargin{:}), in);
end
