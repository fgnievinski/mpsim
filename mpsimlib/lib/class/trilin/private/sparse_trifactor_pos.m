function varargout = sparse_trifactor_pos (A, uplow)
    [varargout{1:nargout}] = chol2 (A, uplow);
end


