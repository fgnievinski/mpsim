function varargout = subsasgn (A, s, B)
    try
        [varargout{1:nargout}] = blockdiag(subsasgn(cell(A), s, B));
    catch
        s = lasterror;
        s.identifier = strrep (s.identifier, 'MATLAB:', 'blockdiag:subsasgn:');
        error(s);
    end        
end

%!test

