function varargout = fevalc (f, vec)
    [varargout{1:nargout}] = deal_vec2arg (f, vec, true);
end
