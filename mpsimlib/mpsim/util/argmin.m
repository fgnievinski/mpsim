function i = argmin(x, varargin)
    [ignore, i] = min(x, varargin{:}); %#ok<ASGLU>
end

