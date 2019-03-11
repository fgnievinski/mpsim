function out = mydateday (varargin)
%MYDATEDAY: Convert epoch interval to (decimal) days.
    out = mydatehour(varargin{:}) ./ 24;
end
