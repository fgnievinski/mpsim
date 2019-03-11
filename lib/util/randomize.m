function out = randomize (in, varargin)
  out = in(argsort(rand(size(in)), varargin{:}));
end

