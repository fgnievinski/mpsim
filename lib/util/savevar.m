function savevar (filename, variable, varargin) %#ok<INUSL>
    save(filename, 'variable', varargin{:})
end
