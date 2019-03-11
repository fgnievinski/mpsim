function out = mydatemin (varargin)
%MYDATEMIN: Convert epoch interval to (decimal) minutes.
    out = mydatesec(varargin{:}) ./ 60;
end
