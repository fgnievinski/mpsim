function i = argmax(x, varargin)
    [ignore, i] = max(x, varargin{:}); %#ok<ASGLU>
end

